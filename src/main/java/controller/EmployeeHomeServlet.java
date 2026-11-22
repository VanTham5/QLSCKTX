package controller;

import dao.SuCoDAO;
import dao.TaiKhoanDAO;
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

        if (!"NHAN_VIEN".equals(acc.getVaiTro())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            request.setAttribute("staffTeam", new TaiKhoanDAO().getStaffTeam(acc.getTaiKhoanId()));
        } catch (java.sql.SQLException e) {
            log("Không tải được thông tin tổ kỹ thuật", e);
            request.setAttribute("staffTeamError", true);
        }

        SuCoDAO dao = new SuCoDAO();

        // 1. Lấy danh sách sự cố (chỉ lấy Chờ xử lý và Đang xử lý để hiện bảng bên dưới)
        List<SuCo> listSuCo = dao.getAllSuCoForStaff(acc.getTaiKhoanId());

        // 2. Đếm số lượng chờ xử lý và đang xử lý từ danh sách
        int pending = 0, processing = 0;
        if (listSuCo != null) {
            for (SuCo sc : listSuCo) {
                if ("Chờ xử lý".equals(sc.getTrangThai())) {
                    pending++;
                } else if ("Đang xử lý".equals(sc.getTrangThai())) {
                    processing++;
                }
            }
        }

        // 3. Lấy số lượng đã hoàn thành trong tháng từ database bằng hàm riêng
        int done = dao.countCompletedIssuesThisMonth(acc.getTaiKhoanId());

        // 4. Đẩy sang JSP
        String filter = request.getParameter("filter");
        if ("pending".equals(filter) || "processing".equals(filter)) {
            String status = "pending".equals(filter) ? "Chờ xử lý" : "Đang xử lý";
            listSuCo = listSuCo.stream()
                    .filter(issue -> status.equals(issue.getTrangThai()))
                    .collect(java.util.stream.Collectors.toList());
            request.setAttribute("workFilter", filter);
            request.setAttribute("workListTitle", status);
        }

        request.setAttribute("listSuCo", listSuCo);
        request.setAttribute("pending", pending);
        request.setAttribute("processing", processing);
        request.setAttribute("done", done);
        request.setAttribute("employeeProfile", new TaiKhoanDAO().getEmployeeProfile(acc.getTaiKhoanId()));
        request.setAttribute("employeeProfileReturnTo", "home");
        request.setAttribute("changePasswordReturnTo", "/employee-home");
        request.setAttribute("maintenanceNoticeReturnTo", "home");

        request.getRequestDispatcher("/employee/employee_home.jsp").forward(request, response);
    }
}