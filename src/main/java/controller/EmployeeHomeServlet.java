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
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

        request.setAttribute("employeeProfile", new TaiKhoanDAO().getEmployeeProfile(acc.getTaiKhoanId()));

        if ("team".equals(request.getParameter("view"))) {
            request.setAttribute("teamView", true);
            request.setAttribute("pending", new SuCoDAO().countPendingIssuesForStaff(acc.getTaiKhoanId()));
            try {
                request.setAttribute("staffTeam", new TaiKhoanDAO().getStaffTeam(acc.getTaiKhoanId()));
            } catch (java.sql.SQLException e) {
                log("Không tải được thông tin tổ kỹ thuật", e);
                request.setAttribute("staffTeamError", true);
            }
            request.getRequestDispatcher("/employee/employee_home.jsp").forward(request, response);
            return;
        }

        SuCoDAO dao = new SuCoDAO();

        // 1. Lấy danh sách sự cố (chỉ lấy Chờ xử lý và Đang xử lý để hiện bảng bên dưới)
        List<SuCo> listSuCo = dao.getAllSuCoForStaff(acc.getTaiKhoanId());

        boolean statisticsView = "statistics".equals(request.getParameter("view"));
        YearMonth month = null;
        String selectedMonth = request.getParameter("month");
        if (statisticsView && selectedMonth != null && selectedMonth.matches("[1-9][0-9]{3}-[0-9]{2}")) {
            try {
                month = YearMonth.parse(selectedMonth);
            } catch (DateTimeParseException ignored) {
                // Hiển thị tất cả khi tham số không hợp lệ.
            }
        }
        request.setAttribute("statisticsView", statisticsView);
        request.setAttribute("statisticsMonth", month == null ? null : month.toString());
        request.setAttribute("statisticsMonthLabel", month == null ? null : month.format(DateTimeFormatter.ofPattern("MM/yyyy")));

        int sidebarPending = 0;
        int pending = 0, processing = 0;
        Map<String, Integer> openByPriority = new LinkedHashMap<>();
        openByPriority.put("Khẩn cấp", 0);
        openByPriority.put("Trung bình", 0);
        openByPriority.put("Thấp", 0);
        if (listSuCo != null) {
            for (SuCo sc : listSuCo) {
                if ("Chờ xử lý".equals(sc.getTrangThai())) {
                    sidebarPending++;
                }
                if (month != null && (sc.getNgayGui() == null
                        || !month.equals(YearMonth.from(sc.getNgayGui().toLocalDateTime())))) {
                    continue;
                }
                String priority = sc.getMucDo();
                if ("KHẨN CẤP".equals(priority)) {
                    openByPriority.merge("Khẩn cấp", 1, Integer::sum);
                } else if ("TRUNG BÌNH".equals(priority)) {
                    openByPriority.merge("Trung bình", 1, Integer::sum);
                } else if ("THẤP".equals(priority)) {
                    openByPriority.merge("Thấp", 1, Integer::sum);
                } else {
                    openByPriority.merge("Khác", 1, Integer::sum);
                }
                if ("Chờ xử lý".equals(sc.getTrangThai())) {
                    pending++;
                } else if ("Đang xử lý".equals(sc.getTrangThai())) {
                    processing++;
                }
            }
        }

        int done = statisticsView
                ? dao.countCompletedIssuesForStaff(acc.getTaiKhoanId(), month)
                : dao.countCompletedIssuesThisMonth(acc.getTaiKhoanId());

        // Đẩy dữ liệu sang JSP
        String filter = statisticsView ? null : request.getParameter("filter");
        if ("pending".equals(filter) || "processing".equals(filter)) {
            String status = "pending".equals(filter) ? "Chờ xử lý" : "Đang xử lý";
            listSuCo = listSuCo.stream()
                    .filter(issue -> status.equals(issue.getTrangThai()))
                    .collect(java.util.stream.Collectors.toList());
            request.setAttribute("workFilter", filter);
            request.setAttribute("workListTitle", status);
        }

        request.setAttribute("listSuCo", statisticsView ? null : listSuCo);
        request.setAttribute("openByPriority", openByPriority);
        request.setAttribute("pending", pending);
        request.setAttribute("sidebarPending", sidebarPending);
        request.setAttribute("processing", processing);
        request.setAttribute("done", done);

        request.getRequestDispatcher("/employee/employee_home.jsp").forward(request, response);
    }
}