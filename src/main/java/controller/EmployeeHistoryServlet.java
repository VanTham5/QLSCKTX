package controller;

import dao.SuCoDAO;
import model.TaiKhoan;
import model.SuCo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "EmployeeHistoryServlet", urlPatterns = {"/employee-history"})
public class EmployeeHistoryServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String filter = request.getParameter("filter");
        if (filter == null) {
            filter = "all";
        }

        SuCoDAO dao = new SuCoDAO();
        // Sửa lại đúng tên hàm trong SuCoDAO là getAllSuCoHistoryForStaff
        List<SuCo> historyList = dao.getAllSuCoHistoryForStaff(acc.getTaiKhoanId(), filter);
        request.setAttribute("historyList", historyList);

        request.getRequestDispatcher("employee/employee_history.jsp").forward(request, response);
    }
}