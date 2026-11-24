package controller;

import dao.SuCoDAO;
import dao.TaiKhoanDAO;
import model.SuCo;
import model.LoaiSuCo;
import model.TaiKhoan;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

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

        List<LoaiSuCo> listLoaiSuCo = dao.getAllLoaiSuCo();
        request.setAttribute("listLoaiSuCo", listLoaiSuCo);

        // Lấy thống kê
        request.setAttribute("total", dao.countIssueByStatus(tkId, null));
        request.setAttribute("pending", dao.countIssueByStatus(tkId, "Chờ xử lý"));
        request.setAttribute("processing", dao.countIssueByStatus(tkId, "Đang xử lý"));
        request.setAttribute("done", dao.countIssueByStatus(tkId, "Đã hoàn thành"));

        // Lấy danh sách 5 sự cố mới nhất
        List<SuCo> recentList = dao.getTop5RecentIssues(tkId);
        request.setAttribute("recentList", recentList);

        //LẤY THÔNG BÁO
        StudentNoticeServlet.loadInitialBatch(request);

        // Gọi DAO lấy dữ liệu thống kê loại sự cố
        SuCoDAO suCoDao = new SuCoDAO();
        Map<String, Integer> thongKeMap = suCoDao.getThongKeTheoLoai();

        // Gọi DAO lấy danh sách 3 cập nhật mới nhất
        suCoDao = new SuCoDAO();
        List<model.SuCo> listCapNhat = suCoDao.getTop3CapNhat();
        request.setAttribute("listCapNhat", listCapNhat);

        //Đẩy sang request
        request.setAttribute("thongKeMap", thongKeMap);

        // Chuyển hướng sang giao diện JSP
        TaiKhoanDAO accountDao = new TaiKhoanDAO();
        request.setAttribute("studentProfile", accountDao.getStudentProfile(acc.getTaiKhoanId()));
        request.setAttribute("profileRooms", accountDao.getProfileRooms());

        request.getRequestDispatcher("student/student_home.jsp").forward(request, response);
    }
}