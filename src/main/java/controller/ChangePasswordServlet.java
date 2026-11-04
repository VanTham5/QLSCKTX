package controller;

import dao.TaiKhoanDAO;
import model.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        TaiKhoan acc = (TaiKhoan) request.getSession().getAttribute("acc");
        if (acc == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String oldPass = request.getParameter("oldPass");
        String newPass = request.getParameter("newPass");

        TaiKhoanDAO dao = new TaiKhoanDAO();
        boolean isSuccess = dao.changePassword(acc.getTaiKhoanId(), oldPass, newPass);

        // Cập nhật xong thì chuyển hướng về trang chủ
        response.sendRedirect(request.getContextPath() + "/student-home");
    }
}