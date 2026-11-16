package controller;

import dao.SuCoDAO;
import model.SuCo;
import model.TaiKhoan;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminHomeServlet", urlPatterns = {"/admin-home"})
public class AdminHomeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        // Bảo mật: Đuổi về trang login nếu chưa đăng nhập hoặc không phải ADMIN
        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect("login.jsp");
            return;
        }

        SuCoDAO dao = new SuCoDAO();

        // 1. CHỈ LẤY DANH SÁCH SỰ CỐ "CHỜ XỬ LÝ" CHO BẢNG CHÍNH TRANG CHỦ
        List<SuCo> listSuCo = dao.getPendingSuCoForAdmin();

        // 2. TÍNH TOÁN SỐ LIỆU THỐNG KÊ TỔNG QUAN CHO CÁC THẺ STAT CARD
        int total = dao.getAllSuCoForAdmin("all").size();       // Tổng số sự cố toàn hệ thống
        int pending = listSuCo.size();                          // Số lượng đang chờ xử lý
        int processing = dao.getAllSuCoForAdmin("processing").size(); // Số lượng đang tiến hành sửa chữa
        int totalStudents = dao.countTotalStudents();           // Tổng sinh viên nội trú

        // 3. ĐẨY DỮ LIỆU SANG JSP
        request.setAttribute("listSuCo", listSuCo);
        request.setAttribute("total", total);
        request.setAttribute("pending", pending);
        request.setAttribute("processing", processing);
        request.setAttribute("totalStudents", totalStudents);

        // Điều hướng về giao diện trang chủ Admin
        request.getRequestDispatcher("/admin/admin_home.jsp").forward(request, response);
    }
}