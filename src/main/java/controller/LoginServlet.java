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

// Chú thích này giúp map đường dẫn URL /login vào Servlet này
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    // Xử lý khi người dùng nhấn submit form (phương thức POST)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Lấy dữ liệu từ form HTML
        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        TaiKhoanDAO dao = new TaiKhoanDAO();
        TaiKhoan tk = dao.checkLogin(user, pass);

        if (tk == null) {
            // Đăng nhập thất bại: Gửi câu thông báo lỗi về lại trang login.jsp
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng, hoặc tài khoản bị khóa!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            // Đăng nhập thành công: Lưu thông tin vào Session
            HttpSession session = request.getSession();
            session.setAttribute("acc", tk);

            // Điều hướng dựa trên vai trò (Role)
            String role = tk.getVaiTro();
            if ("ADMIN".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/admin_home.jsp");
            } else if ("NHAN_VIEN".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/employee/employee_home.jsp");
            } else {
                // Đã sửa: Trỏ thẳng vào đường dẫn của StudentHomeServlet (bỏ chữ student/)
                response.sendRedirect(request.getContextPath() + "/student-home");
            }
        }
    }

    // Xử lý khi người dùng gõ /login lên thanh địa chỉ (phương thức GET)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}