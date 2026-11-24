package controller;

import jakarta.servlet.http.HttpServletRequest;

final class AdminPage {
    static final int SIZE = 15;

    private AdminPage() {
    }

    static int offset(HttpServletRequest request, int total) {
        int page = requestedPage(request);
        int lastPage = Math.max(1, (int) Math.ceil(total / (double) SIZE));
        page = Math.max(1, Math.min(page, lastPage));
        request.setAttribute("pageNumber", page);
        request.setAttribute("lastPage", lastPage);
        request.setAttribute("totalRows", total);
        return (page - 1) * SIZE;
    }

    static int requestedPage(HttpServletRequest request) {
        try {
            return Math.max(1, Integer.parseInt(request.getParameter("page")));
        } catch (NumberFormatException ignored) {
            return 1;
        }
    }
}
