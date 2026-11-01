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
        List<SuCo> listSuCo = dao.getAllSuCoForStaff(); // Admin dùng chung hàm lấy danh sách với Nhân viên

        int total = listSuCo.size();
        int pending = 0, processing = 0;
        for (SuCo sc : listSuCo) {
            if ("Chờ xử lý".equals(sc.getTrangThai())) pending++;
            else if ("Đang xử lý".equals(sc.getTrangThai())) processing++;
        }

        request.setAttribute("listSuCo", listSuCo);
        request.setAttribute("total", total);
        request.setAttribute("pending", pending);
        request.setAttribute("processing", processing);
        request.setAttribute("totalStudents", dao.countTotalStudents());

        // Đổi đường dẫn admin_home.jsp cho khớp với cấu trúc thư mục của bạn
        request.getRequestDispatcher("/admin/admin_home.jsp").forward(request, response);
    }
}