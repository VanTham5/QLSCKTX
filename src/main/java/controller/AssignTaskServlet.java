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

@WebServlet(name = "AssignTaskServlet", urlPatterns = {"/assign-task"})
public class AssignTaskServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        // Kiểm tra bảo mật: Chỉ Admin mới được phân công
        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect("login.jsp");
            return;
        }

        boolean assigned = false;
        try {
            int issueId = Integer.parseInt(request.getParameter("suCoId"));
            int staffAccountId = Integer.parseInt(request.getParameter("nhanVienId"));
            assigned = new SuCoDAO().assignStaffToIssue(issueId, staffAccountId);
        } catch (Exception e) {
            log("Không thể phân công sự cố", e);
        }

        response.sendRedirect(request.getContextPath() + "/admin-home?assignment="
                + (assigned ? "success" : "failed") + "&page=" + AdminPage.requestedPage(request));
    }
}
