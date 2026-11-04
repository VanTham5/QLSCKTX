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
        String fullName = request.getParameter("fullName");
        String sdt = request.getParameter("sdt");
        String email = request.getParameter("email");

        TaiKhoanDAO dao = new TaiKhoanDAO();
        boolean isSuccess = false;

        // Phân quyền cập nhật dựa trên Vai trò
        if ("SINH_VIEN".equals(acc.getVaiTro())) {
            int phongId = Integer.parseInt(request.getParameter("phongId"));
            String maSV = request.getParameter("maSV");
            String khoa = request.getParameter("khoa");
            String lop = request.getParameter("lop");

            isSuccess = dao.updateProfileStudent(acc.getTaiKhoanId(), fullName, sdt, email, phongId, maSV, khoa, lop);
        } else {
            // Dành cho ADMIN và NHAN_VIEN
            isSuccess = dao.updateProfileEmployee(acc.getTaiKhoanId(), fullName, sdt, email);
        }

        // Cập nhật lại Session để hiển thị tên mới lập tức
        if (isSuccess) {
            acc.setHoTen(fullName);
            session.setAttribute("acc", acc);
        }

        // Chuyển hướng về đúng trang của từng vai trò
        if ("SINH_VIEN".equals(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/student-home");
        } else if ("NHAN_VIEN".equals(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/employee-home");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-home");
        }
    }
}