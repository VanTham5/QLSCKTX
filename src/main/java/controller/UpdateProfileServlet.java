package controller;

import dao.TaiKhoanDAO;
import model.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "UpdateProfileServlet", urlPatterns = {"/update-profile"})
public class UpdateProfileServlet extends HttpServlet {

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

        // Lấy các trường thông tin chung (bảng tai_khoan)
        String fullName = FormValidation.trim(request.getParameter("fullName"));
        String sdt = FormValidation.trim(request.getParameter("sdt"));
        String email = FormValidation.trim(request.getParameter("email"));

        TaiKhoanDAO dao = new TaiKhoanDAO();
        boolean isSuccess = false;
        boolean contactValid = FormValidation.text(fullName, 1, 100) && FormValidation.contact(sdt, email);
        if (!"ADMIN".equals(acc.getVaiTro())) {
            contactValid = contactValid && !sdt.isEmpty();
        }

        // Phân quyền cập nhật dựa trên Vai trò
        if ("SINH_VIEN".equals(acc.getVaiTro())) {
            int phongId;
            try {
                phongId = Integer.parseInt(request.getParameter("phongId"));
            } catch (NumberFormatException e) {
                phongId = 0;
            }
            String maSV = FormValidation.trim(request.getParameter("maSV"));
            String khoa = FormValidation.trim(request.getParameter("khoa"));
            String lop = FormValidation.trim(request.getParameter("lop"));

            if (contactValid && phongId > 0 && FormValidation.text(maSV, 1, 20)
                    && FormValidation.text(khoa, 1, 100) && FormValidation.text(lop, 1, 50)) {
                isSuccess = dao.updateProfileStudent(acc.getTaiKhoanId(), fullName, sdt, email, phongId, maSV, khoa, lop);
            }
        } else if ("NHAN_VIEN".equals(acc.getVaiTro())) {
            if (contactValid) {
                isSuccess = dao.updateProfileEmployee(acc.getTaiKhoanId(), fullName, sdt, email);
            }
        } else {
            // Dành cho ADMIN
            if (contactValid) {
                isSuccess = dao.updateProfileEmployee(acc.getTaiKhoanId(), fullName, sdt, email);
            }
        }

        // Cập nhật lại Session để hiển thị thông tin mới lập tức
        if (isSuccess) {
            acc.setHoTen(fullName);
            acc.setSoDienThoai(sdt);
            acc.setEmail(email);
            session.setAttribute("acc", acc);
        }

        // Chuyển hướng về đúng trang của từng vai trò
        if ("SINH_VIEN".equals(acc.getVaiTro())) {
            String studentPage = "history".equals(request.getParameter("profilePage"))
                    ? "/student-history" : "/student-home";
            response.sendRedirect(request.getContextPath() + studentPage
                    + "?profileUpdate=" + (isSuccess ? "success" : "failed"));
        } else if ("NHAN_VIEN".equals(acc.getVaiTro())) {
            String page = "history".equals(request.getParameter("profilePage"))
                    ? "/employee-history" : "/employee-home";
            response.sendRedirect(request.getContextPath() + page
                    + "?profileUpdate=" + (isSuccess ? "success" : "failed"));
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-home?profileUpdate=" + (isSuccess ? "success" : "failed"));
        }
    }
}
