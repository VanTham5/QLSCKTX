package controller;

import dao.SuCoDAO;
import model.SuCo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "EmployeeHomeServlet", urlPatterns = {"/employee-home"})
public class EmployeeHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        dao.SuCoDAO dao = new dao.SuCoDAO();

        // 1. Lấy danh sách toàn bộ sự cố
        List<model.SuCo> listSuCo = dao.getAllSuCoForStaff();

        // 2. Tính toán số liệu thống kê (Đếm số lượng theo từng trạng thái)
        int pending = 0, processing = 0, done = 0;
        if (listSuCo != null) {
            for (model.SuCo sc : listSuCo) {
                if ("Chờ xử lý".equals(sc.getTrangThai())) pending++;
                else if ("Đang xử lý".equals(sc.getTrangThai())) processing++;
                else if ("Đã hoàn thành".equals(sc.getTrangThai())) done++;
            }
        }

        // 3. Đẩy dữ liệu sang JSP
        request.setAttribute("listSuCo", listSuCo);
        request.setAttribute("pending", pending);
        request.setAttribute("processing", processing);
        request.setAttribute("done", done);

        request.getRequestDispatcher("/employee/employee_home.jsp").forward(request, response);
    }
}