function createIncidentPagination(rowSelector, emptyRowId) {
    const container = document.getElementById('incidentPagination');
    const emptyRow = document.getElementById(emptyRowId);
    const rows = Array.from(document.querySelectorAll(rowSelector));
    const summary = container.querySelector('[data-page-summary]');
    const numbers = container.querySelector('[data-page-numbers]');
    const previous = container.querySelector('[data-page-prev]');
    const next = container.querySelector('[data-page-next]');
    const pageSize = 10;
    let matches = rows;
    let currentPage = 1;

    function render() {
        const lastPage = Math.max(1, Math.ceil(matches.length / pageSize));
        const start = (currentPage - 1) * pageSize;
        const end = Math.min(start + pageSize, matches.length);
        const visibleRows = new Set(matches.slice(start, end));
        rows.forEach(row => { row.hidden = !visibleRows.has(row); });
        emptyRow.hidden = rows.length === 0 || matches.length > 0;

        container.hidden = lastPage === 1;
        summary.textContent = `Trang ${currentPage} / ${lastPage}`;
        previous.setAttribute('aria-disabled', String(currentPage === 1));
        next.setAttribute('aria-disabled', String(currentPage === lastPage));
        numbers.replaceChildren();

        const pages = [...new Set([1, currentPage - 1, currentPage, currentPage + 1, lastPage])]
            .filter(page => page >= 1 && page <= lastPage)
            .sort((a, b) => a - b);
        pages.forEach((page, index) => {
            if (index > 0 && page - pages[index - 1] > 1) {
                const gap = document.createElement('span');
                gap.className = 'incident-pagination__gap';
                gap.textContent = '…';
                gap.setAttribute('aria-hidden', 'true');
                numbers.appendChild(gap);
            }
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'incident-pagination__control';
            button.textContent = page;
            button.setAttribute('aria-label', 'Trang ' + page);
            if (page === currentPage) button.setAttribute('aria-current', 'page');
            button.addEventListener('click', () => {
                if (page === currentPage) return;
                currentPage = page;
                render();
                numbers.querySelector('[aria-current="page"]').focus();
            });
            numbers.appendChild(button);
        });
    }

    previous.addEventListener('click', () => {
        if (currentPage <= 1) return;
        currentPage--;
        render();
    });
    next.addEventListener('click', () => {
        if (currentPage * pageSize >= matches.length) return;
        currentPage++;
        render();
    });

    return {
        get page() {
            return currentPage;
        },
        update(predicate, orderedRows = rows, page = 1) {
            matches = orderedRows.filter(predicate);
            currentPage = Math.min(page, Math.max(1, Math.ceil(matches.length / pageSize)));
            render();
            return matches.length;
        }
    };
}
