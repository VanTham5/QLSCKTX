package controller;

import dao.ThongBaoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ThongBao;

import java.io.IOException;
import java.util.List;

@WebServlet("/student-notices")
public class StudentNoticeServlet extends HttpServlet {
    private static final int BATCH_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int beforeId;
        try {
            beforeId = Integer.parseInt(request.getParameter("before"));
        } catch (NumberFormatException ignored) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (beforeId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        loadBatch(request, beforeId);
        response.setHeader("Cache-Control", "no-store");
        request.getRequestDispatcher("/WEB-INF/student_notice_batch.jsp").forward(request, response);
    }

    static void loadInitialBatch(HttpServletRequest request) {
        try {
            loadBatch(request, 0);
        } catch (ServletException e) {
            request.getServletContext().log("Cannot load initial student notices", e);
            request.setAttribute("noticesUnavailable", true);
        }
    }

    private static void loadBatch(HttpServletRequest request, int beforeId) throws ServletException {
        try {
            List<ThongBao> notices = new ThongBaoDAO().getNoticeBatch(beforeId, BATCH_SIZE + 1);
            if (notices.size() > BATCH_SIZE) {
                request.setAttribute("nextNoticeBefore", notices.get(BATCH_SIZE - 1).getId());
                notices = notices.subList(0, BATCH_SIZE);
            }
            request.setAttribute("listTB", notices);
        } catch (Exception e) {
            throw new ServletException("Cannot load student notices", e);
        }
    }
}
