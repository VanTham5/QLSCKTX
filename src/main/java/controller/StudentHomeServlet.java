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

@WebServlet(name = "StudentHomeServlet", urlPatterns = {"/student-home"})
public class StudentHomeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        SuCoDAO dao = new SuCoDAO();
        int tkId = acc.getTaiKhoanId();

        // Lấy thống kê
        request.setAttribute("total", dao.countIssueByStatus(tkId, null));
        request.setAttribute("pending", dao.countIssueByStatus(tkId, "Chờ xử lý"));
        request.setAttribute("processing", dao.countIssueByStatus(tkId, "Đang xử lý"));
        request.setAttribute("done", dao.countIssueByStatus(tkId, "Đã hoàn thành"));

        // Lấy danh sách 5 sự cố mới nhất
        List<SuCo> recentList = dao.getTop5RecentIssues(tkId);
        request.setAttribute("recentList", recentList);

        // Chuyển hướng sang giao diện JSP
        request.getRequestDispatcher("student/student_home.jsp").forward(request, response);
    }
}