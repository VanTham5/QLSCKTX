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
    private static final int HTTP_UNPROCESSABLE_CONTENT = 422;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        boolean ajax = "fetch".equals(request.getHeader("X-Requested-With"));
        HttpSession session = request.getSession(false);
        TaiKhoan acc = session == null ? null : (TaiKhoan) session.getAttribute("acc");

        if (acc == null) {
            if (ajax) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                response.sendRedirect("login.jsp");
            }
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
            if (ajax) {
                response.setStatus(HTTP_UNPROCESSABLE_CONTENT);
            } else {
                response.sendRedirect(returnUrl + "statusUpdate=note");
            }
            return;
        }

        int issueId = FormValidation.positiveId(request.getParameter("suCoId"));
        int result = HttpServletResponse.SC_BAD_REQUEST;
        if (issueId > 0 && (completed || "Đang xử lý".equals(status))) {
            try {
                boolean updated = new SuCoDAO().updateStaffIssue(acc.getTaiKhoanId(), issueId,
                        completed, completed ? note.trim() : null);
                result = updated ? HttpServletResponse.SC_NO_CONTENT : HttpServletResponse.SC_CONFLICT;
            } catch (java.sql.SQLException e) {
                log("Không thể cập nhật trạng thái sự cố", e);
                result = HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
            }
        }

        if (ajax) {
            response.setStatus(result);
        } else {
            response.sendRedirect(returnUrl + "statusUpdate="
                    + (result == HttpServletResponse.SC_NO_CONTENT ? "success" : "failed"));
        }
    }
}
