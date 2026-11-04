package controller;

import dao.TaiKhoanDAO; // Sửa lại tên DAO chứa hàm register của bạn

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    // Gọi phương thức GET để hiển thị trang giao diện đăng ký
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    // Gọi phương thức POST khi người dùng bấm nút "Đăng ký"
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8"); // Sửa lỗi font tiếng Việt

        String username = request.getParameter("username");
        String fullName = request.getParameter("fullName");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate cơ bản ở Backend
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        TaiKhoanDAO dao = new TaiKhoanDAO(); // Đổi thành DAO bạn đang dùng
        boolean isSuccess = dao.registerStudent(username, password, fullName);

        if (isSuccess) {
            // Chuyển hướng sang trang đăng nhập kèm thông báo thành công
            request.setAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            // Tên đăng nhập bị trùng hoặc lỗi DB
            request.setAttribute("error", "Tên đăng nhập (Mã SV) đã tồn tại hoặc có lỗi xảy ra!");
            request.setAttribute("oldUsername", username);
            request.setAttribute("oldFullName", fullName);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}