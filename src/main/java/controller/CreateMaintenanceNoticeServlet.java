package controller;

import dao.ThongBaoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.TaiKhoan;

@WebServlet(name = "CreateMaintenanceNoticeServlet", urlPatterns = {"/create-maintenance-notice"})
public class CreateMaintenanceNoticeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        TaiKhoan account = session == null ? null : (TaiKhoan) session.getAttribute("acc");

        if (account == null || !"NHAN_VIEN".equals(account.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String title = request.getParameter("tieuDe");
        String content = request.getParameter("noiDung");
        boolean valid = title != null && !title.trim().isEmpty() && title.trim().length() <= 190
                && content != null && !content.trim().isEmpty() && content.trim().length() <= 10000;
        boolean success = false;
        if (valid) {
            String maintenanceTitle = title.trim().startsWith("[Bảo trì]")
                    ? title.trim() : "[Bảo trì] " + title.trim();
            success = new ThongBaoDAO().insertThongBao(
                    maintenanceTitle, content.trim(), account.getTaiKhoanId());
        }

        String target = "history".equals(request.getParameter("returnTo"))
                ? "/employee-history" : "/employee-home";
        response.sendRedirect(request.getContextPath() + target + "?maintenanceNotice="
                + (success ? "success" : "failed"));
    }
}
