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

@WebServlet(name = "AdminIncidentListServlet", urlPatterns = {"/admin-incidents"})
public class AdminIncidentListServlet extends HttpServlet {
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
        List<SuCo> listSuCo = dao.getAllSuCoForAdmin(filter);

        // Đếm số lượng sự cố chờ xử lý để hiển thị badge trên sidebar menu
        int pending = dao.getAllSuCoForAdmin("pending").size();

        request.setAttribute("listSuCo", listSuCo);
        request.setAttribute("pending", pending);

        request.getRequestDispatcher("/admin/admin_incident_list.jsp").forward(request, response);
    }
}