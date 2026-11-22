package controller;

import dao.TaiKhoanDAO;
import jakarta.servlet.ServletException;
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String oldPass = request.getParameter("oldPass");
        String newPass = request.getParameter("newPass");
        String returnTo = request.getParameter("returnTo");

        boolean success = newPass != null && newPass.length() >= 6
                && new TaiKhoanDAO().changePassword(acc.getTaiKhoanId(), oldPass, newPass);
        String target;
        if ("SINH_VIEN".equals(acc.getVaiTro())) {
            target = "/student-history".equals(returnTo) ? "/student-history" : "/student-home";
        } else if ("NHAN_VIEN".equals(acc.getVaiTro())) {
            target = "/employee-history".equals(returnTo) ? "/employee-history" : "/employee-home";
        } else if ("ADMIN".equals(acc.getVaiTro())) {
            target = "/admin-home";
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String result = success ? "?msg=pass_success" : "?error="
                + (newPass != null && newPass.length() < 6 ? "weak_new_pass" : "wrong_old_pass");
        response.sendRedirect(request.getContextPath() + target + result);
    }
}
//okokokokokok