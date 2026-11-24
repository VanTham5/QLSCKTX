(() => {
    const message = document.getElementById('adminListMessage');
    let list = document.getElementById('adminList');
    let requestVersion = 0;
    let timer;
    let updatingAccount = false;

    function restoreFilters(url) {
        for (const select of list.querySelectorAll('select[name]')) {
            const value = url.searchParams.get(select.name) || '';
            if (Array.from(select.options).some(option => option.value === value)) select.value = value;
        }
    }

    async function loadList(url, addHistory = true) {
        const version = ++requestVersion;
        list.setAttribute('aria-busy', 'true');
        message.textContent = '';
        try {
            const response = await fetch(url, { cache: 'no-store' });
            if (!response.ok) throw new Error('List request failed');
            const next = new DOMParser().parseFromString(await response.text(), 'text/html');
            if (version !== requestVersion) return;
            const replacement = next.getElementById('adminList');
            if (!replacement) {
                if (response.redirected) { location.assign(response.url); return; }
                throw new Error('Missing list');
            }
            const focused = list.contains(document.activeElement) ? document.activeElement : null;
            const activeId = focused?.id;
            const selection = focused?.type === 'text' ? focused.selectionStart : null;
            list.replaceWith(replacement);
            list = replacement;
            const details = document.getElementById('adminListDetails');
            const replacementDetails = next.getElementById('adminListDetails');
            if (details && replacementDetails) details.replaceWith(replacementDetails);
            if (addHistory && url.href !== location.href) history.pushState(null, '', url.href);
            restoreFilters(url);
            if (activeId) {
                const newControl = document.getElementById(activeId);
                newControl?.focus();
                if (selection !== null) newControl?.setSelectionRange(selection, selection);
            } else if (focused?.closest('.incident-pagination')) {
                list.querySelector('.incident-pagination [aria-current="page"]')?.focus({ preventScroll: true });
            }
        } catch {
            if (version === requestVersion) message.textContent = 'Không tải được danh sách. Vui lòng thử lại.';
        } finally {
            if (version === requestVersion) list.removeAttribute('aria-busy');
        }
    }

    function filterUrl() {
        const url = new URL(location.href);
        url.searchParams.delete('page');
        for (const field of list.querySelectorAll('[name="q"], select[name]')) {
            if (field.value.trim()) url.searchParams.set(field.name, field.value.trim());
            else url.searchParams.delete(field.name);
        }
        return url;
    }

    document.addEventListener('click', event => {
        const link = event.target.closest('#adminList [data-list-link]');
        if (!link || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
        event.preventDefault();
        if (updatingAccount) return;
        clearTimeout(timer);
        const url = new URL(link.href);
        if (link.hasAttribute('data-list-tab')) {
            const next = filterUrl();
            const key = list.dataset.tabParam;
            next.searchParams.set(key, url.searchParams.get(key));
            loadList(next);
        } else {
            loadList(url);
        }
    });

    document.addEventListener('input', event => {
        if (!event.target.matches('#adminList [name="q"]') || updatingAccount) return;
        clearTimeout(timer);
        ++requestVersion;
        timer = setTimeout(() => loadList(filterUrl()), 280);
    });

    document.addEventListener('change', event => {
        if (!event.target.matches('#adminList select[name]') || updatingAccount) return;
        clearTimeout(timer);
        loadList(filterUrl());
    });

    document.addEventListener('submit', async event => {
        const form = event.target;
        if (form.matches('[data-list-filters]')) {
            event.preventDefault();
            clearTimeout(timer);
            if (!updatingAccount) loadList(filterUrl());
            return;
        }
        if (!list.contains(form) || form.elements.namedItem('action')?.value !== 'updateStatus') return;
        event.preventDefault();
        if (updatingAccount || !window.confirm(form.elements.trangThaiMoi.value === '0'
                ? 'Khóa tài khoản này?' : 'Mở khóa tài khoản này?')) return;
        clearTimeout(timer);
        ++requestVersion;
        updatingAccount = true;
        const button = event.submitter;
        if (button) button.disabled = true;
        try {
            const response = await fetch(form.getAttribute('action'), {
                method: 'POST',
                body: new URLSearchParams(new FormData(form)),
                headers: { 'X-Requested-With': 'fetch' }
            });
            if (response.redirected) { location.assign(response.url); return; }
            if (response.status !== 204) throw new Error('Account status request failed');
            await loadList(new URL(location.href), false);
        } catch {
            message.textContent = 'Không thể cập nhật trạng thái tài khoản. Vui lòng thử lại.';
        } finally {
            if (button) button.disabled = false;
            updatingAccount = false;
        }
    });

    window.addEventListener('popstate', () => {
        clearTimeout(timer);
        loadList(new URL(location.href), false);
    });
    restoreFilters(new URL(location.href));
})();
