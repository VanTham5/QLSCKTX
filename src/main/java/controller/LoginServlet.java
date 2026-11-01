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

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Nếu người dùng gõ trực tiếp /login trên URL thì đẩy về trang giao diện
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy dữ liệu từ form HTML (thuộc tính name="username" và name="password")
        String u = request.getParameter("username");
        String p = request.getParameter("password");

        // 2. Gọi DAO để kiểm tra trong Database
        TaiKhoanDAO dao = new TaiKhoanDAO();
        TaiKhoan acc = dao.checkLogin(u, p); // Lưu ý: Đảm bảo hàm checkLogin của bạn tên giống thế này

        // 3. Xử lý logic phân quyền
        if (acc != null) {
            // Đăng nhập đúng -> Lưu vào session
            HttpSession session = request.getSession();
            session.setAttribute("acc", acc);

            // Lấy vai trò từ CSDL
            String vaiTro = acc.getVaiTro();

            // Điều hướng dựa trên vai trò
            if ("SINH_VIEN".equals(vaiTro)) {
                response.sendRedirect(request.getContextPath() + "/student-home");
            }
            else if ("NHAN_VIEN".equals(vaiTro)) {
                response.sendRedirect(request.getContextPath() + "/employee-home");
            }
            else if ("ADMIN".equals(vaiTro)) {
                // Tạm thời chưa có admin-home, có thể sửa sau khi làm trang Admin
                response.sendRedirect(request.getContextPath() + "/admin-home");
            }
            else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
        } else {
            // Đăng nhập sai -> Trả về lỗi
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}