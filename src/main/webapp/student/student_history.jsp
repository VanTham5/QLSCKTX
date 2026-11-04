<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Báo Cáo - KTX Support</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow-x: hidden; }
        .sidebar { width: 260px; background-color: #ffffff; height: 100vh; position: fixed; left: 0; top: 0; border-right: 1px solid #e0e0e0; z-index: 1000; }
        .main-content { margin-left: 260px; min-height: 100vh; padding-bottom: 30px; }
        .sidebar .nav-link { color: #4b5563; padding: 12px 20px; font-weight: 500; border-left: 3px solid transparent; }
        .sidebar .nav-link:hover, .sidebar .nav-link.active { background-color: #f3f4f6; color: #0d6efd; border-left: 3px solid #0d6efd; }
        .sidebar-heading { font-size: 0.75rem; text-transform: uppercase; color: #9ca3af; font-weight: bold; padding: 10px 20px; margin-top: 15px; }
        .w-20px { width: 22px; text-align: center; }
        .top-header { background-color: #ffffff; height: 60px; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: flex-end; align-items: center; padding: 0 30px; position: sticky; top: 0; z-index: 999; }
        .filter-btn.active { font-weight: bold; border-color: #0d6efd; color: #0d6efd; background-color: #f8f9fa; }
    </style>
</head>
<body>

<!-- SIDEBAR -->
<div class="sidebar d-flex flex-column" style="overflow-y: auto;">
    <div class="d-flex align-items-center p-3" style="height: 60px; border-bottom: 1px solid #e0e0e0;">
        <i class="fa-solid fa-building-shield fs-4 text-warning me-2"></i>
        <h5 class="mb-0 fw-bold text-dark" style="font-size: 1.1rem;">KTX - ĐHCNHN</h5>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="${pageContext.request.contextPath}/student-home" class="nav-link"><i class="fa-solid fa-house me-2 w-20px"></i> Trang chủ</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-bell me-2 w-20px"></i> Thông báo từ BQL</a>

    <div class="sidebar-heading">Dịch vụ KTX</div>
    <a href="${pageContext.request.contextPath}/student-home" class="nav-link"><i class="fa-solid fa-wrench me-2 w-20px"></i> Báo cáo sự cố</a>
    <!-- Active state for history page -->
    <a href="${pageContext.request.contextPath}/student-history" class="nav-link active"><i class="fa-solid fa-list-check me-2 w-20px"></i> Lịch sử báo cáo</a>

    <div class="sidebar-heading">Trợ giúp & Liên hệ</div>
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#guideModal">
        <i class="fa-solid fa-book me-2 w-20px"></i> Hướng dẫn & Nội quy
    </a>
    <a href="tel:0123456789" class="nav-link fw-bold text-success"><i class="fa-solid fa-phone-volume me-2 w-20px"></i> Hotline: 0123.456.789</a>

    <div class="sidebar-heading">Tài khoản</div>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-danger mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- HEADER TOP -->
    <div class="top-header">
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'SV'}&background=random" alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-bold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Sinh Viên'}</span>
                <i class="fa-solid fa-chevron-down ms-2" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4 mt-4">

        <h4 class="fw-bold text-dark mb-4"><i class="fa-solid fa-list-check text-primary me-2"></i>Lịch sử báo cáo sự cố</h4>

        <!-- TÙY CHỈNH LỌC TRẠNG THÁI -->
        <% String currentFilter = request.getParameter("filter"); %>
        <div class="btn-group mb-4 shadow-sm" role="group">
            <a href="?filter=all" class="btn btn-outline-secondary filter-btn <%= (currentFilter == null || currentFilter.equals("all")) ? "active" : "" %>">Tất cả</a>
            <a href="?filter=pending" class="btn btn-outline-secondary filter-btn <%= "pending".equals(currentFilter) ? "active text-warning" : "" %>">Chờ xử lý</a>
            <a href="?filter=processing" class="btn btn-outline-secondary filter-btn <%= "processing".equals(currentFilter) ? "active text-primary" : "" %>">Đang xử lý</a>
            <a href="?filter=done" class="btn btn-outline-secondary filter-btn <%= "done".equals(currentFilter) ? "active text-success" : "" %>">Đã hoàn thành</a>
        </div>

        <!-- BẢNG LỊCH SỬ -->
        <div class="card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ SC</th>
                            <th class="fw-medium py-3">TIÊU ĐỀ SỰ CỐ</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">NGÀY GỬI</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="pe-4 fw-medium py-3 text-center">CHI TIẾT</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<SuCo> historyList = (List<SuCo>) request.getAttribute("historyList");
                            if (historyList != null && !historyList.isEmpty()) {
                                for (SuCo task : historyList) {
                                    String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
                                    String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary">#SC0<%= task.getSuCoId() %></span></td>
                            <td>
                                <div class="fw-bold text-dark"><%= task.getTieuDe() %></div>
                            </td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>"><%= task.getMucDo() %></span></td>
                            <td class="text-muted" style="font-size: 0.9rem;"><%= task.getNgayGui() %></td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= "Chờ xử lý".equals(task.getTrangThai()) ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>
                            <td class="pe-4 text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#historyDetailModal<%= task.getSuCoId() %>" title="Xem chi tiết">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted">Không tìm thấy báo cáo nào trong mục này.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- VÒNG LẶP MODAL CHI TIẾT LỊCH SỬ -->
<%
    if (historyList != null && !historyList.isEmpty()) {
        for (SuCo task : historyList) {
            String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
            String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
%>
<div class="modal fade" id="historyDetailModal<%= task.getSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-info text-dark">
                <h5 class="modal-title fw-bold">Chi tiết sự cố #SC0<%= task.getSuCoId() %></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <h6 class="fw-bold text-primary mb-3"><%= task.getTieuDe() %></h6>
                <div class="mb-2"><strong>Mức độ:</strong> <span class="badge bg-<%= badgeMucDo %>"><%= task.getMucDo() %></span></div>
                <div class="mb-2"><strong>Trạng thái:</strong> <span class="badge bg-<%= badgeTrangThai %>"><%= task.getTrangThai() %></span></div>
                <div class="mb-2"><strong>Ngày báo cáo:</strong> <%= task.getNgayGui() %></div>
                <hr>
                <div class="mb-1 fw-bold">Mô tả chi tiết:</div>
                <div class="p-3 bg-light rounded border">
                    <%= task.getMoTa() %>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>
<%
        }
    }
%>

<!-- MODAL HƯỚNG DẪN & NỘI QUY -->
<div class="modal fade" id="guideModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-book-open me-2"></i>Hướng dẫn & Nội quy KTX</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4 text-start">

                <!-- PHẦN 1: HƯỚNG DẪN -->
                <h6 class="fw-bold text-primary mb-3"><i class="fa-solid fa-circle-info me-2"></i>1. Hướng dẫn báo cáo sự cố</h6>
                <div class="mb-4 text-muted" style="font-size: 0.95rem;">
                    <ul class="mb-0">
                        <li class="mb-2"><strong>Bước 1:</strong> Chọn mục "Báo cáo sự cố" trên menu.</li>
                        <li class="mb-2"><strong>Bước 2:</strong> Điền đầy đủ Tiêu đề, Danh mục, Mức độ và Mô tả chi tiết tình trạng hư hỏng.</li>
                        <li class="mb-2"><strong>Bước 3:</strong> Nhấn "Gửi Báo Cáo". Bộ phận kỹ thuật sẽ tiếp nhận và xử lý theo mức độ ưu tiên.</li>
                        <li><em>Lưu ý:</em> Sinh viên có thể theo dõi tiến độ sửa chữa tại mục "Lịch sử báo cáo".</li>
                    </ul>
                </div>

                <hr>

                <!-- PHẦN 2: NỘI QUY -->
                <h6 class="fw-bold text-danger mb-3 mt-4"><i class="fa-solid fa-triangle-exclamation me-2"></i>2. Nội quy Ký túc xá</h6>
                <div class="text-muted" style="font-size: 0.95rem;">
                    <ul class="mb-0">
                        <li class="mb-2">Không tự ý sửa chữa, tháo lắp hệ thống điện, nước, hoặc thay đổi kết cấu phòng ở.</li>
                        <li class="mb-2">Nghiêm cấm sử dụng các thiết bị điện có công suất lớn (bếp từ, bếp hồng ngoại, ấm siêu tốc...) trong phòng để phòng chống cháy nổ.</li>
                        <li class="mb-2">Giữ gìn vệ sinh chung, đổ rác đúng nơi và đúng giờ quy định.</li>
                        <li>Nếu phát hiện hư hỏng cơ sở vật chất, phải báo cáo ngay cho Ban Quản Lý (BQL) qua hệ thống này.</li>
                    </ul>
                </div>

            </div>

            <!-- PHẦN 3: FOOTER (TRỢ GIÚP & LIÊN HỆ) -->
            <div class="modal-footer bg-light d-flex justify-content-between align-items-center">
                <div class="text-start" style="font-size: 0.9rem;">
                    <div class="fw-bold text-dark mb-1">Trợ giúp & Liên hệ Ban Quản Lý:</div>
                    <div><i class="fa-solid fa-phone-volume text-success me-2"></i>Hotline: <strong>0123.456.789</strong></div>
                    <div><i class="fa-solid fa-envelope text-primary me-2"></i>Email: <strong>hotro.ktx@dhcnhn.edu.vn</strong></div>
                </div>
                <button type="button" class="btn btn-secondary fw-medium px-4" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>