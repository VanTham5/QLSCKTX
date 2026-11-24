package controller;

import dao.TaiKhoanDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.TaiKhoan;
import java.io.IOException;

@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        TaiKhoan account = session == null ? null : (TaiKhoan) session.getAttribute("acc");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String oldPassword = request.getParameter("oldPass");
        String newPassword = request.getParameter("newPass");
        boolean confirmed = newPassword != null && newPassword.equals(request.getParameter("confirmPass"));
        boolean valid = oldPassword != null && !oldPassword.isEmpty()
                && FormValidation.password(newPassword) && confirmed;
        boolean changed = valid && new TaiKhoanDAO().changePassword(account.getTaiKhoanId(), oldPassword, newPassword);

        String role = account.getVaiTro();
        boolean history = "history".equals(request.getParameter("profilePage"));
        String destination;
        String result;
        if ("NHAN_VIEN".equals(role)) {
            destination = history ? "/employee-history" : "/employee-home";
            result = "passwordUpdate=" + (!valid ? "invalid" : changed ? "success" : "failed");
        } else if ("ADMIN".equals(role)) {
            destination = "/admin-home";
            if (changed) {
                result = "msg=pass_success";
            } else if (oldPassword == null || oldPassword.isEmpty() || newPassword == null || newPassword.trim().isEmpty()) {
                result = "passError=empty";
            } else if (!confirmed) {
                result = "passError=mismatch";
            } else {
                result = !valid ? "passError=short" : "error=wrong_old_pass";
            }
        } else {
            destination = history ? "/student-history" : "/student-home";
            result = !valid ? "passError=invalid" : changed ? "msg=pass_success" : "error=wrong_old_pass";
        }
        response.sendRedirect(request.getContextPath() + destination + "?" + result);
    }
}
