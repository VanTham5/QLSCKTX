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

@WebServlet(name = "StudentHistoryServlet", urlPatterns = {"/student-history"})
public class StudentHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");
        if (acc == null || !"SINH_VIEN".equals(acc.getVaiTro())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 2. Nhận bộ lọc từ URL (khi người dùng bấm vào các nút lọc)
        String filter = request.getParameter("filter");
        if (filter == null) {
            filter = "all"; // Mặc định mở trang lên là xem tất cả
        }

        // 3. Gọi DAO để lấy danh sách theo đúng bộ lọc
        SuCoDAO dao = new SuCoDAO();
        List<SuCo> historyList = dao.getHistoryIssues(acc.getTaiKhoanId(), filter);

        // 4. Trả dữ liệu về giao diện
        request.setAttribute("historyList", historyList);

        // Trỏ về đúng file giao diện của bạn (Lưu ý: đường dẫn có thể là /student/student_history.jsp tùy cách bạn tổ chức thư mục)
        request.getRequestDispatcher("student/student_history.jsp").forward(request, response);
    }
}