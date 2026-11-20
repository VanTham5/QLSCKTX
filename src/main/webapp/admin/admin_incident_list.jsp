<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Sự Cố - Quản Trị Hệ Thống</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f4f6f9; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        .sidebar { width: 260px; background-color: #343a40; height: 100vh; position: fixed; left: 0; top: 0; z-index: 1000; }
        .main-content { margin-left: 260px; min-height: 100vh; padding-bottom: 30px; }
        .sidebar .nav-link { color: #c2c7d0; padding: 12px 20px; font-weight: 500; border-left: 3px solid transparent; }
        .sidebar .nav-link:hover, .sidebar .nav-link.active { background-color: rgba(255,255,255,0.1); color: #ffffff; border-left: 3px solid #0d6efd; }
        .sidebar-heading { font-size: 0.75rem; text-transform: uppercase; color: #6c757d; font-weight: bold; padding: 10px 20px; margin-top: 15px; }
        .w-20px { width: 22px; text-align: center; }
        .top-header { background-color: #ffffff; height: 60px; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: flex-end; align-items: center; padding: 0 30px; position: sticky; top: 0; z-index: 999; }
        .filter-btn.active { font-weight: bold; border-color: #0d6efd; color: #0d6efd; background-color: #f8f9fa; }
    </style>
</head>
<body>

<!-- SIDEBAR ADMIN (ĐỒNG BỘ 100% VỚI TRANG CHỦ) -->
<div class="sidebar d-flex flex-column" style="overflow-y: auto;">
    <div class="d-flex align-items-center p-3 border-bottom border-secondary" style="height: 60px;">
        <i class="fa-solid fa-server fs-4 text-primary me-2"></i>
        <h5 class="mb-0 fw-bold text-white" style="font-size: 1.1rem;">QUẢN TRỊ HỆ THỐNG</h5>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="${pageContext.request.contextPath}/admin-home" class="nav-link"><i class="fa-solid fa-chart-line me-2 w-20px"></i> Bảng điều khiển</a>

    <div class="sidebar-heading">Nghiệp vụ</div>
    <!-- Nút mở Modal Đăng thông báo hoạt động trên mọi trang -->
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#createNoticeModal">
        <i class="fa-solid fa-bullhorn me-2 w-20px"></i> Đăng thông báo
    </a>
    <a href="${pageContext.request.contextPath}/admin-incidents" class="nav-link active d-flex justify-content-between align-items-center">
        <span><i class="fa-solid fa-triangle-exclamation me-2 w-20px"></i> Quản lý sự cố</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin-accounts" class="nav-link">
        <i class="fa-solid fa-users me-2 w-20px"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin-phong" class="nav-link"><i class="fa-solid fa-building me-2 w-20px"></i> Quản lý phòng/tòa</a>    <a href="${pageContext.request.contextPath}/admin-loai-su-co" class="nav-link"><i class="fa-solid fa-list me-2 w-20px"></i> Danh mục loại sự cố</a>

    <div class="sidebar-heading">Hệ thống</div>
    <a href="#" class="nav-link"><i class="fa-solid fa-gear me-2 w-20px"></i> Cài đặt</a>
    <a href="${pageContext.request.contextPath}/login.jsp" class="nav-link text-danger mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- HEADER TOP -->
    <div class="top-header">
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Admin'}&background=random" alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-bold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Quản trị viên'}</span>
                <i class="fa-solid fa-chevron-down ms-2" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/login.jsp">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4 mt-4">

        <h4 class="fw-bold text-dark mb-4"><i class="fa-solid fa-triangle-exclamation text-primary me-2"></i>Quản lý toàn bộ sự cố hệ thống</h4>

        <!-- BỘ LỌC TRẠNG THÁI -->
        <% String currentFilter = request.getParameter("filter"); %>
        <div class="btn-group mb-4 shadow-sm" role="group">
            <a href="?filter=all" class="btn btn-outline-secondary filter-btn <%= (currentFilter == null || currentFilter.equals("all")) ? "active" : "" %>">Tất cả</a>
            <a href="?filter=pending" class="btn btn-outline-secondary filter-btn <%= "pending".equals(currentFilter) ? "active text-warning" : "" %>">Chờ xử lý</a>
            <a href="?filter=processing" class="btn btn-outline-secondary filter-btn <%= "processing".equals(currentFilter) ? "active text-primary" : "" %>">Đang xử lý</a>
            <a href="?filter=done" class="btn btn-outline-secondary filter-btn <%= "done".equals(currentFilter) ? "active text-success" : "" %>">Đã hoàn thành</a>
        </div>

        <!-- BẢNG DANH SÁCH SỰ CỐ -->
        <div class="card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ SC</th>
                            <th class="fw-medium py-3">TIÊU ĐỀ SỰ CỐ</th>
                            <th class="fw-medium py-3">NGƯỜI BÁO CÁO</th>
                            <th class="fw-medium py-3">SĐT LIÊN HỆ</th>
                            <th class="fw-medium py-3">VỊ TRÍ</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="pe-4 fw-medium py-3 text-center">CHI TIẾT</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<SuCo> listSuCo = (List<SuCo>) request.getAttribute("listSuCo");
                            if (listSuCo != null && !listSuCo.isEmpty()) {
                                for (SuCo task : listSuCo) {
                                    String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
                                    String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
                                    String tenNguoiGui = task.getTenNguoiGui();
                                    String sdtNguoiGui = task.getSoDienThoai();
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary">#SC0<%= task.getSuCoId() %></span></td>
                            <td>
                                <div class="fw-bold text-dark"><%= task.getTieuDe() %></div>
                                <div class="text-muted" style="font-size: 0.8rem;">Gửi lúc: <%= task.getNgayGui() %></div>
                            </td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(tenNguoiGui, "UTF-8") %>&background=random" class="rounded-circle me-2" width="28">
                                    <span class="fw-medium"><%= tenNguoiGui %></span>
                                </div>
                            </td>
                            <td>
                                <a href="tel:<%= sdtNguoiGui %>" class="text-decoration-none fw-medium text-primary">
                                    <i class="fa-solid fa-phone fa-sm me-1"></i> <%= sdtNguoiGui %>
                                </a>
                            </td>
                            <td><span class="fw-medium text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> <%= task.getViTriPhong() %></span></td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>"><%= task.getMucDo() %></span></td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= "Chờ xử lý".equals(task.getTrangThai()) ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>
                            <td class="pe-4 text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#detailModal<%= task.getSuCoId() %>" title="Xem chi tiết">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">Không tìm thấy sự cố nào trong hệ thống.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- MODAL ĐĂNG THÔNG BÁO TỪ ADMIN (ĐÃ ĐƯỢC ĐỒNG BỘ SANG TRANG NÀY) -->
<div class="modal fade" id="createNoticeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-bullhorn me-2"></i>Đăng Thông Báo Mới</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <form action="${pageContext.request.contextPath}/create-thongbao" method="POST">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tiêu đề thông báo <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="tieuDe" placeholder="VD: Lịch phun muỗi toàn KTX..." required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-bold">Nội dung chi tiết <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="noiDung" rows="5" placeholder="Nhập nội dung thông báo gửi đến sinh viên..." required></textarea>
                    </div>
                    <div class="d-flex justify-content-end">
                        <button type="button" class="btn btn-light border me-2" data-bs-dismiss="modal">Hủy bỏ</button>
                        <button type="submit" class="btn btn-primary fw-bold">Phát hành ngay</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- VÒNG LẶP MODAL CHI TIẾT SỰ CỐ -->
<%
    if (listSuCo != null && !listSuCo.isEmpty()) {
        for (SuCo task : listSuCo) {
            String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
            String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
%>
<div class="modal fade" id="detailModal<%= task.getSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-circle-info me-2"></i>Chi tiết sự cố #SC0<%= task.getSuCoId() %></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <h6 class="fw-bold text-primary mb-3"><%= task.getTieuDe() %></h6>
                <div class="mb-2"><strong>Người báo cáo:</strong> <span class="fw-bold text-dark"><%= task.getTenNguoiGui() %></span></div>
                <div class="mb-2">
                    <strong>Số điện thoại:</strong>
                    <a href="tel:<%= task.getSoDienThoai() %>" class="text-decoration-none fw-bold text-primary">
                        <i class="fa-solid fa-phone me-1"></i> <%= task.getSoDienThoai() %>
                    </a>
                </div>
                <div class="mb-2"><strong>Vị trí phòng:</strong> <span class="text-danger fw-medium"><%= task.getViTriPhong() %></span></div>
                <div class="mb-2"><strong>Mức độ:</strong> <span class="badge bg-<%= badgeMucDo %>"><%= task.getMucDo() %></span></div>
                <div class="mb-2"><strong>Trạng thái:</strong> <span class="badge bg-<%= badgeTrangThai %>"><%= task.getTrangThai() %></span></div>
                <div class="mb-2"><strong>Ngày báo cáo:</strong> <%= task.getNgayGui() %></div>
                <hr>
                <div class="mb-1 fw-bold text-dark">Mô tả chi tiết từ sinh viên:</div>
                <div class="p-3 bg-light rounded border text-muted" style="font-size: 0.95rem;">
                    <%= task.getMoTa() != null ? task.getMoTa() : "Không có mô tả chi tiết." %>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>
<%
        }
    }
%>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>