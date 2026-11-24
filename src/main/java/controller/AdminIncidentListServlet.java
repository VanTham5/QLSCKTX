package controller;

import dao.SuCoDAO;
import model.TaiKhoan;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AdminIncidentListServlet", urlPatterns = {"/admin-incidents"})
public class AdminIncidentListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String filter = request.getParameter("filter");
        if (!"pending".equals(filter) && !"processing".equals(filter) && !"done".equals(filter)) {
            filter = "all";
        }
        String priority = FormValidation.trim(request.getParameter("priority"));
        if (!"THẤP".equals(priority) && !"TRUNG BÌNH".equals(priority) && !"KHẨN CẤP".equals(priority)) {
            priority = "";
        }
        String keyword = FormValidation.trim(request.getParameter("q"));
        if (keyword.length() > 100) {
            keyword = keyword.substring(0, 100);
        }
        SuCoDAO dao = new SuCoDAO();
        int total = dao.countAdminIncidents(filter, priority, keyword);
        int offset = AdminPage.offset(request, total);
        request.setAttribute("listSuCo", dao.getAdminIncidents(filter, priority, keyword, AdminPage.SIZE, offset));
        request.setAttribute("currentFilter", filter);
        request.setAttribute("priorityFilter", priority);
        request.setAttribute("keyword", keyword);
        request.setAttribute("pending", dao.countAdminIncidents("pending", "", ""));

        request.getRequestDispatcher("/admin/admin_incident_list.jsp").forward(request, response);
    }
}