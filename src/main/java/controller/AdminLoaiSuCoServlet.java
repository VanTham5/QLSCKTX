package controller;

import dao.LoaiSuCoDAO;
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

@WebServlet(name = "AdminLoaiSuCoServlet", urlPatterns = {"/admin-loai-su-co"})
public class AdminLoaiSuCoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan acc = (TaiKhoan) session.getAttribute("acc");

        if (acc == null || !"ADMIN".equals(acc.getVaiTro())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        LoaiSuCoDAO dao = new LoaiSuCoDAO();

        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteLoaiSuCo(id);
            response.sendRedirect("admin-loai-su-co");
            return;
        }

        List<LoaiSuCo> list = dao.getAllLoaiSuCo();
        request.setAttribute("listLoaiSuCo", list);
        request.getRequestDispatcher("admin/admin_loai_su_co.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        LoaiSuCoDAO dao = new LoaiSuCoDAO();

        if ("add".equals(action)) {
            String tenLoai = request.getParameter("tenLoai");
            int toId = Integer.parseInt(request.getParameter("toId"));
            String moTa = request.getParameter("moTa");
            dao.insertLoaiSuCo(tenLoai, toId, moTa);
        } else if ("edit".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String tenLoai = request.getParameter("tenLoai");
            int toId = Integer.parseInt(request.getParameter("toId"));
            String moTa = request.getParameter("moTa");
            dao.updateLoaiSuCo(id, tenLoai, toId, moTa);
        }

        response.sendRedirect("admin-loai-su-co");
    }
}