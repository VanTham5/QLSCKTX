(() => {
    let table = document.getElementById('employeeWorkTable');
    if (!table) return;

    const details = document.getElementById('employeeWorkDetails');
    const heading = document.getElementById('work-list');
    const search = document.getElementById('incidentSearch');
    const date = document.getElementById('incidentDate');
    const priority = document.getElementById('incidentPriority');
    const feedback = document.getElementById('employeeWorkFeedback');
    const status = document.getElementById('employeeWorkStatus');
    const retry = document.getElementById('retryEmployeeWorkRefresh');
    const counts = Array.from(document.querySelectorAll('[data-work-count]'));

    const modal = document.getElementById('confirmActionModal');
    const form = document.getElementById('confirmActionForm');
    const submit = document.getElementById('confirmModalSubmitBtn');
    const note = document.getElementById('repairNote');
    const error = document.getElementById('confirmActionError');
    let actionButton;

    const createPagination = () => createIncidentPagination('#employeeWorkTable .incident-row', 'noIncidentMatches');
    let pagination = createPagination();

    function normalize(text) {
        return text.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');
    }

    function filterIncidents(page = 1) {
        const query = normalize(search.value.trim());
        const roomQuery = query.replace(/^p(?=\d)/, '');
        pagination.update(row => {
            const code = normalize(row.cells[0].textContent);
            const title = normalize(row.cells[1].querySelector('.fw-bold').textContent);
            const location = normalize(row.cells[2].textContent);
            return (!date.value || row.dataset.reportDate === date.value)
                && (!priority.value || row.dataset.mucdo === priority.value)
                && (code.includes(query) || title.includes(query) || location.includes(roomQuery));
        }, undefined, page);
    }

    search.addEventListener('input', () => filterIncidents());
    date.addEventListener('input', () => filterIncidents());
    priority.addEventListener('change', () => filterIncidents());
    filterIncidents();

    document.addEventListener('click', event => {
        const button = event.target.closest('#employeeWorkTable [data-suco-id]');
        if (!button || table.inert) return;

        actionButton = button;
        const data = button.dataset;
        const completed = data.trangThai === 'Đã hoàn thành';
        const issue = button.closest('tr').cells[1].querySelector('.fw-bold').textContent.trim();
        document.getElementById('confirmActionTitle').textContent = data.title;
        document.getElementById('confirmModalMessage').textContent = completed
            ? `Xác nhận sự cố “${issue}” đã sửa xong?`
            : `Bạn có muốn nhận xử lý sự cố “${issue}” không?`;
        form.elements.suCoId.value = data.sucoId;
        form.elements.trangThaiMoi.value = data.trangThai;
        document.getElementById('repairNoteField').hidden = !completed;
        note.value = '';
        note.disabled = !completed;
        note.required = completed;
        error.hidden = true;
        submit.className = 'btn px-4 fw-bold text-white ' + data.btnClass;
        submit.textContent = data.btnText;
        bootstrap.Modal.getOrCreateInstance(modal).show(button);
    });

    modal.addEventListener('hide.bs.modal', event => {
        if (submit.disabled) event.preventDefault();
    });
    modal.addEventListener('hidden.bs.modal', () => {
        const row = actionButton?.closest('tr');
        const target = row && !row.hidden && actionButton.isConnected && !table.inert ? actionButton : heading;
        target.focus({ preventScroll: true });
    });

    async function refreshWorkList() {
        retry.disabled = true;
        retry.hidden = true;
        table.inert = true;
        table.setAttribute('aria-busy', 'true');
        feedback.hidden = false;
        status.textContent = 'Đã lưu thay đổi. Đang cập nhật danh sách…';

        try {
            const url = new URL(location.href);
            url.searchParams.delete('statusUpdate');
            const response = await fetch(url, { cache: 'no-store' });
            if (!response.ok || response.redirected) throw new Error('Work list request failed');

            const page = new DOMParser().parseFromString(await response.text(), 'text/html');
            const newTable = page.getElementById(table.id);
            const newDetails = page.getElementById(details.id);
            const newCounts = counts.map(count =>
                page.querySelector(`[data-work-count="${count.dataset.workCount}"]`));
            if (!newTable || !newDetails || newCounts.some(count => !count)) {
                throw new Error('Missing work list content');
            }

            const currentPage = pagination.page;
            table.replaceWith(newTable);
            table = newTable;
            details.replaceChildren(...newDetails.children);
            counts.forEach((count, index) => { count.textContent = newCounts[index].textContent; });
            pagination = createPagination();
            filterIncidents(currentPage);
            status.className = 'text-success';
            status.textContent = 'Đã cập nhật sự cố.';
        } catch {
            status.className = 'text-warning-emphasis';
            status.textContent = 'Đã lưu sự cố. Chưa tải được danh sách mới.';
            retry.hidden = false;
        } finally {
            retry.disabled = false;
            table.removeAttribute('aria-busy');
        }
    }

    retry.addEventListener('click', refreshWorkList);

    form.addEventListener('submit', async event => {
        event.preventDefault();
        if (submit.disabled || table.inert) return;

        const body = new URLSearchParams(new FormData(form));
        if (note.required && !note.value.trim()) {
            error.textContent = 'Nhập ghi chú sửa chữa từ 1 đến 2.000 ký tự.';
            error.hidden = false;
            note.focus();
            return;
        }

        error.hidden = true;
        const label = submit.textContent;
        submit.disabled = true;
        submit.textContent = 'Đang lưu…';
        note.readOnly = true;
        let saved = false;

        try {
            const response = await fetch(form.action, {
                method: 'POST',
                headers: { 'X-Requested-With': 'fetch' },
                body
            });
            saved = response.status === 204 && !response.redirected;
            if (!saved) {
                if (response.status === 422) {
                    error.textContent = 'Nhập ghi chú sửa chữa từ 1 đến 2.000 ký tự.';
                } else if (response.status === 401 || response.redirected) {
                    error.textContent = 'Phiên đăng nhập đã hết. Ghi chú vẫn còn trong cửa sổ này.';
                } else if (response.status === 409) {
                    error.textContent = 'Sự cố đã đổi trạng thái hoặc không còn được phân công cho bạn.';
                } else {
                    error.textContent = 'Không thể cập nhật sự cố. Vui lòng thử lại.';
                }
            }
        } catch {
            error.textContent = 'Mất kết nối khi gửi yêu cầu. Hãy kiểm tra lại trạng thái sự cố.';
        } finally {
            submit.disabled = false;
            submit.textContent = label;
            note.readOnly = false;
        }

        if (!saved) {
            error.hidden = false;
            return;
        }

        bootstrap.Modal.getOrCreateInstance(modal).hide();
        await refreshWorkList();
    });
})();
