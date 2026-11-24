package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.TaiKhoan;

import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String uri = req.getRequestURI();
        String path = uri.substring(contextPath.length());

        // 1. Cho phép đi qua các tài nguyên tĩnh và trang công khai
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/")
                || path.startsWith("/assets/") || path.endsWith(".css") || path.endsWith(".js")
                || path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".ico")
                || path.equals("/") || path.equals("/index.jsp")
                || path.equals("/login") || path.equals("/login.jsp")
                || path.equals("/register") || path.equals("/register.jsp")
                || path.equals("/logout")) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Xác định các nhóm đường dẫn cần bảo vệ theo vai trò
        boolean isAdminPath = path.startsWith("/admin-") || path.startsWith("/admin/") || path.startsWith("/admin_");
        boolean isEmployeePath = path.startsWith("/employee-") || path.startsWith("/employee/") || path.startsWith("/employee_");
        boolean isStudentPath = path.startsWith("/student-") || path.startsWith("/student/") || path.startsWith("/student_");

        if (isAdminPath || isEmployeePath || isStudentPath) {
            HttpSession session = req.getSession(false);
            TaiKhoan acc = (session != null) ? (TaiKhoan) session.getAttribute("acc") : null;

            // Chưa đăng nhập -> đẩy về trang đăng nhập
            if (acc == null) {
                res.sendRedirect(contextPath + "/login.jsp");
                return;
            }

            String role = acc.getVaiTro();

            // Kiểm tra đúng vai trò, nếu cố truy cập trái phép -> đẩy về đúng trang chủ của họ
            if (isAdminPath && !"ADMIN".equalsIgnoreCase(role)) {
                redirectToHomeByRole(res, contextPath, role);
                return;
            }
            if (isEmployeePath && !"NHAN_VIEN".equalsIgnoreCase(role)) {
                redirectToHomeByRole(res, contextPath, role);
                return;
            }
            if (isStudentPath && !"SINH_VIEN".equalsIgnoreCase(role)) {
                redirectToHomeByRole(res, contextPath, role);
                return;
            }
        }

        // Hợp lệ -> cho phép đi tiếp tới Servlet / JSP
        chain.doFilter(request, response);
    }

    private void redirectToHomeByRole(HttpServletResponse res, String contextPath, String role) throws IOException {
        if ("ADMIN".equalsIgnoreCase(role)) {
            res.sendRedirect(contextPath + "/admin-home");
        } else if ("NHAN_VIEN".equalsIgnoreCase(role)) {
            res.sendRedirect(contextPath + "/employee-home");
        } else if ("SINH_VIEN".equalsIgnoreCase(role)) {
            res.sendRedirect(contextPath + "/student-home");
        } else {
            res.sendRedirect(contextPath + "/login.jsp");
        }
    }
}