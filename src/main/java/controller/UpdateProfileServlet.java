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
            int phongId;
            try {
                phongId = Integer.parseInt(request.getParameter("phongId"));
            } catch (NumberFormatException e) {
                phongId = 0;
            }
            String maSV = request.getParameter("maSV");
            String khoa = request.getParameter("khoa");
            String lop = request.getParameter("lop");

            if (phongId > 0 && fullName != null && !fullName.trim().isEmpty()
                    && sdt != null && !sdt.trim().isEmpty()
                    && maSV != null && !maSV.trim().isEmpty()
                    && khoa != null && !khoa.trim().isEmpty()
                    && lop != null && !lop.trim().isEmpty()) {
                isSuccess = dao.updateProfileStudent(acc.getTaiKhoanId(), fullName, sdt, email, phongId, maSV, khoa, lop);
            }
        } else {
            // Dành cho ADMIN và NHAN_VIEN
            if (fullName != null && !fullName.trim().isEmpty()
                    && sdt != null && !sdt.trim().isEmpty()) {
                fullName = fullName.trim();
                sdt = sdt.trim();
                email = email == null ? null : email.trim();
                isSuccess = dao.updateProfileEmployee(acc.getTaiKhoanId(), fullName, sdt, email);
            }
        }

        // Cập nhật lại Session để hiển thị tên mới lập tức
        if (isSuccess) {
            acc.setHoTen(fullName);
            acc.setSoDienThoai(sdt);
            session.setAttribute("acc", acc);
        }

        // Chuyển hướng về đúng trang của từng vai trò
        if ("SINH_VIEN".equals(acc.getVaiTro())) {
            String studentPage = "history".equals(request.getParameter("profilePage"))
                    ? "/student-history" : "/student-home";
            response.sendRedirect(request.getContextPath() + studentPage
                    + "?profileUpdate=" + (isSuccess ? "success" : "failed"));
        } else if ("NHAN_VIEN".equals(acc.getVaiTro())) {
            String employeePage = "history".equals(request.getParameter("profilePage"))
                    ? "/employee-history" : "/employee-home";
            response.sendRedirect(request.getContextPath() + employeePage
                    + "?profileUpdate=" + (isSuccess ? "success" : "failed"));
        } else {
            response.sendRedirect(request.getContextPath() + "/admin-home");
        }
    }
}