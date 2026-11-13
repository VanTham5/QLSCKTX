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

@WebServlet(name = "EmployeeHomeServlet", urlPatterns = {"/employee-home"})
public class EmployeeHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Lấy thông tin tài khoản nhân viên từ Session
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        // Kiểm tra đăng nhập
        if (acc == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        SuCoDAO dao = new SuCoDAO();

        // 1. Lấy danh sách sự cố cho nhân viên
        List<SuCo> listSuCo = dao.getAllSuCoForStaff();

        // 2. Tính toán số liệu thống kê (Đếm số lượng theo từng trạng thái)
        int pending = 0, processing = 0, done = 0;
        if (listSuCo != null) {
            for (SuCo sc : listSuCo) {
                if ("Chờ xử lý".equals(sc.getTrangThai())) {
                    pending++;
                } else if ("Đang xử lý".equals(sc.getTrangThai())) {
                    processing++;
                } else if ("Đã hoàn thành".equals(sc.getTrangThai())) {
                    done++;
                }
            }
        }

        // 3. Đẩy dữ liệu sang trang JSP
        request.setAttribute("listSuCo", listSuCo);
        request.setAttribute("pending", pending);
        request.setAttribute("processing", processing);
        request.setAttribute("done", done);

        request.getRequestDispatcher("/employee/employee_home.jsp").forward(request, response);
    }
}