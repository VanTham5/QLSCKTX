package controller;

import dao.SuCoDAO;
import model.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "UpdateStatusServlet", urlPatterns = {"/update-status"})
public class UpdateStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (!"NHAN_VIEN".equals(acc.getVaiTro())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String filter = request.getParameter("workFilter");
        String returnUrl = request.getContextPath() + "/employee-home?";
        if ("pending".equals(filter) || "processing".equals(filter)) {
            returnUrl += "filter=" + filter + "&";
        }

        String status = request.getParameter("trangThaiMoi");
        boolean completed = "Đã hoàn thành".equals(status);
        String note = request.getParameter("ghiChuKyThuat");
        if (completed && (note == null || note.trim().isEmpty() || note.trim().length() > 2000)) {
            response.sendRedirect(returnUrl + "statusUpdate=note");
            return;
        }

        boolean updated = false;
        try {
            int issueId = Integer.parseInt(request.getParameter("suCoId"));
            if (completed || "Đang xử lý".equals(status)) {
                updated = new SuCoDAO().updateStaffIssue(acc.getTaiKhoanId(), issueId,
                        completed, completed ? note.trim() : null);
            }
        } catch (NumberFormatException | java.sql.SQLException e) {
            log("Không thể cập nhật trạng thái sự cố", e);
        }

        response.sendRedirect(returnUrl + "statusUpdate="
                + (updated ? "success" : "failed"));
    }
}
