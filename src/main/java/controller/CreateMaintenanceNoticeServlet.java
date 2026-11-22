package controller;

import dao.ThongBaoDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.TaiKhoan;
import java.io.IOException;

@WebServlet("/create-maintenance-notice")
public class CreateMaintenanceNoticeServlet extends HttpServlet {
    private static final String TITLE_PREFIX = "[Bảo trì] ";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        TaiKhoan account = session == null ? null : (TaiKhoan) session.getAttribute("acc");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        if (!"NHAN_VIEN".equals(account.getVaiTro())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String title = request.getParameter("tieuDe");
        String content = request.getParameter("noiDung");
        String result = "invalid";
        if (title != null && !title.trim().isEmpty() && title.trim().length() <= 190
                && content != null && !content.trim().isEmpty() && content.trim().length() <= 5000) {
            result = new ThongBaoDAO().insertThongBao(TITLE_PREFIX + title.trim(), content.trim(), account.getTaiKhoanId())
                    ? "success" : "failed";
        }
        String page = "history".equals(request.getParameter("noticePage"))
                ? "/employee-history" : "/employee-home";
        response.sendRedirect(request.getContextPath() + page + "?maintenanceNotice=" + result);
    }
}
