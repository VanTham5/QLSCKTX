(() => {
    const button = document.getElementById('loadMoreNotices');
    if (!button) return;

    const list = document.getElementById('noticeList');
    const status = document.getElementById('noticeLoadStatus');
    const spinner = button.querySelector('.spinner-border');
    let before = list.lastElementChild.dataset.before;

    button.addEventListener('click', async () => {
        if (button.disabled || !before) return;

        button.disabled = true;
        spinner.hidden = false;
        status.textContent = '';
        const url = new URL(button.dataset.url, location.href);
        url.searchParams.set('before', before);
        try {
            const response = await fetch(url);
            if (!response.ok || response.redirected) throw new Error('Notice request failed');

            const template = document.createElement('template');
            template.innerHTML = await response.text();
            const batch = template.content.querySelector('[data-notice-batch]');
            if (!batch) throw new Error('Missing notice batch');

            before = batch.dataset.before;
            const firstHeading = batch.querySelector('h6');
            list.appendChild(batch);
            button.hidden = !before;
            if (firstHeading) firstHeading.focus();
            if (!before) status.textContent = 'Đã hiển thị hết thông báo.';
        } catch {
            status.textContent = 'Chưa tải được thông báo. Vui lòng thử lại.';
        } finally {
            spinner.hidden = true;
            button.disabled = false;
        }
    });
})();
