<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Khởi tạo formatter ngày tháng dùng chung
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Sinh Viên - KTX Support</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background-color: #f0f2f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
        }
        /* ================= SIDEBAR & LAYOUT ĐỒNG BỘ RESPONSIVE ================= */
        .sidebar {
            width: 260px;
            background-color: #ffffff;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            border-right: 1px solid #e0e0e0;
            z-index: 1050;
            transition: width 0.25s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.25s ease;
            overflow-x: hidden !important;
        }
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
            padding-bottom: 30px;
            transition: margin-left 0.25s ease;
        }
        .sidebar .nav-link {
            color: #4b5563;
            padding: 12px 20px;
            font-weight: 500;
            border-left: 3px solid transparent;
            white-space: nowrap;
            display: flex;
            align-items: center;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: #f3f4f6;
            color: #0d6efd;
            border-left: 3px solid #0d6efd;
        }
        .sidebar-heading {
            font-size: 0.75rem;
            text-transform: uppercase;
            color: #9ca3af;
            font-weight: bold;
            padding: 10px 20px;
            margin-top: 15px;
            white-space: nowrap;
        }
        .w-20px {
            width: 22px;
            text-align: center;
            flex-shrink: 0;
        }
        /* Top Header */
        .top-header {
            background-color: #ffffff;
            height: 60px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 0 30px;
            position: sticky;
            top: 0;
            z-index: 999;
        }
        .hero-banner {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #20c997 100%);
            border-radius: 15px;
            color: white;
            padding: 30px;
            margin-top: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .stat-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-3px);
        }
        .icon-box {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        /* Chống gãy chữ trong bảng */
        .table th, .table td {
            white-space: nowrap;
        }
        .table th:nth-child(2), .table td:nth-child(2) {
            white-space: normal;
            min-width: 180px;
        }

        /* ================= TỰ ĐỘNG THU GỌN SIDEBAR & DI CHUỘT HIỆN CHỮ ================= */
        @media (max-width: 1280px) {
            .sidebar { width: 200px; }
            .main-content { margin-left: 200px; }
            .container-fluid.px-4 { padding-left: 14px !important; padding-right: 14px !important; }
        }

        @media (max-width: 992px) {
            /* Mặc định khi màn hình nhỏ: Thu gọn Sidebar còn 68px chỉ hiện icon */
            .sidebar { width: 68px; }
            .sidebar:not(:hover) h5,
            .sidebar:not(:hover) .sidebar-heading { display: none; }
            .sidebar:not(:hover) .nav-link { font-size: 0; justify-content: center; padding: 14px 0; }
            .sidebar:not(:hover) .nav-link i { font-size: 1.15rem; margin: 0 !important; }

            /* Khi di chuột vào Sidebar: Trượt rộng ra 260px và hiện đầy đủ tên các mục */
            .sidebar:hover {
                width: 260px;
                box-shadow: 6px 0 20px rgba(0, 0, 0, 0.15);
            }

            /* Giữ cố định lề nội dung chính 68px */
            .main-content { margin-left: 68px; }
        }
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
    <a href="${pageContext.request.contextPath}/student-home" class="nav-link active">
        <i class="fa-solid fa-house me-2 w-20px"></i> Trang chủ
    </a>
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#noticeModal"><i class="fa-solid fa-bell me-2 w-20px"></i> Thông báo từ BQL</a>
    <div class="sidebar-heading">Dịch vụ KTX</div>
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#reportIssueModal">
        <i class="fa-solid fa-wrench me-2 w-20px"></i> Báo cáo sự cố
    </a>
    <a href="${pageContext.request.contextPath}/student-history" class="nav-link"><i class="fa-solid fa-list-check me-2 w-20px"></i> Lịch sử báo cáo</a>

    <div class="sidebar-heading">Trợ giúp & Liên hệ</div>
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#guideModal">
        <i class="fa-solid fa-book me-2 w-20px"></i> Hướng dẫn & Nội quy
    </a>
    <a href="tel:0123456789" class="nav-link fw-bold text-success"><i class="fa-solid fa-phone-volume me-2 w-20px"></i> Hotline: 0123.456.789</a>

<%@ include file="profile_menu.jspf" %>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-danger mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- HEADER TOP -->
    <div class="top-header">
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'SV'}&background=random" alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-bold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Đỗ Văn Thám'}</span>
                <i class="fa-solid fa-chevron-down ms-2" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#profileModal">Hồ sơ</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4">

        <!-- THÔNG BÁO TỪ BQL (ẩn, chuyển sang trang Thông báo riêng) -->

        <!-- TOAST POPUP: BÁO CÁO SỰ CỐ THÀNH CÔNG -->
<%
    Boolean reportSuccess = (Boolean) session.getAttribute("reportSuccess");
    if (Boolean.TRUE.equals(reportSuccess)) {
        session.removeAttribute("reportSuccess");
%>
        <div id="successToast" class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;">
            <div class="toast show align-items-center text-bg-success border-0 shadow-lg" role="alert" id="toastMsg" style="min-width: 320px;">
                <div class="d-flex">
                    <div class="toast-body d-flex align-items-center gap-2">
                        <i class="fa-solid fa-circle-check fs-4"></i>
                        <div>
                            <div class="fw-bold">Gửi báo cáo thành công!</div>
                            <div style="font-size: 0.85rem;">Sự cố của bạn đã được ghi nhận. BQL sẽ xử lý sớm nhất.</div>
                        </div>
                    </div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        </div>
        <script>
            document.addEventListener("DOMContentLoaded", function() {
                var toastEl = document.getElementById('toastMsg');
                if (toastEl) {
                    var toast = new bootstrap.Toast(toastEl, { delay: 4000 });
                    toast.show();
                }
            });
        </script>
<% } %>

        <!-- NÚT BÁO CÁO SỰ CỐ -->
        <div class="d-flex justify-content-start mb-4">
            <button class="btn btn-primary fw-bold shadow-sm rounded-pill px-4 py-2" data-bs-toggle="modal" data-bs-target="#reportIssueModal">
                <i class="fa-solid fa-plus me-2"></i> Báo cáo sự cố
            </button>
        </div>

        <!-- THỐNG KÊ NHANH (Tự động chia 2 cột đẹp mắt khi thu nhỏ và 4 cột khi mở rộng) -->
        <div class="row g-3 g-md-4 mt-1">
            <!-- Thẻ 1: Tổng sự cố đã gửi -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center">
                    <div class="icon-box bg-danger bg-opacity-10 text-danger me-3">
                        <i class="fa-solid fa-file-invoice"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">${total != null ? total : 0}</h4>
                        <span class="text-muted small">Tổng báo cáo đã gửi</span>
                    </div>
                </div>
            </div>

            <!-- Thẻ 2: Sự cố chờ xử lý -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center">
                    <div class="icon-box bg-warning bg-opacity-10 text-warning me-3">
                        <i class="fa-solid fa-hourglass-half"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">${pending != null ? pending : 0}</h4>
                        <span class="text-muted small">Sự cố chờ xử lý</span>
                    </div>
                </div>
            </div>

            <!-- Thẻ 3: Sự cố đang xử lý -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center">
                    <div class="icon-box bg-primary bg-opacity-10 text-primary me-3">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">${processing != null ? processing : 0}</h4>
                        <span class="text-muted small">Sự cố đang xử lý</span>
                    </div>
                </div>
            </div>

            <!-- Thẻ 4: Sự cố đã hoàn thành -->
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center">
                    <div class="icon-box bg-success bg-opacity-10 text-success me-3">
                        <i class="fa-solid fa-check-double"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">${done != null ? done : 0}</h4>
                        <span class="text-muted small">Sự cố đã hoàn thành</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG DANH SÁCH SỰ CỐ GẦN ĐÂY -->
        <div class="d-flex justify-content-between align-items-center mt-5 mb-3">
            <h5 class="fw-bold mb-0">Danh sách sự cố gần đây</h5>
            <a href="${pageContext.request.contextPath}/student-history" class="text-decoration-none text-primary fw-medium">Xem tất cả <i class="fa-solid fa-arrow-right fs-6 ms-1"></i></a>
        </div>

        <div class="card stat-card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ SC</th>
                            <th class="fw-medium py-3">TIÊU ĐỀ SỰ CỐ</th>
                            <th class="fw-medium py-3">DANH MỤC</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">NGÀY GỬI</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<SuCo> recentList = (List<SuCo>) request.getAttribute("recentList");
                            if (recentList != null && !recentList.isEmpty()) {
                                for (SuCo task : recentList) {
                                    String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
                                    String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary">#SC0<%= task.getSuCoId() %></span></td>
                            <td>
                                <div class="fw-bold text-dark"><%= task.getTieuDe() %></div>
                                <div class="text-muted" style="font-size: 0.8rem;"><i class="fa-solid fa-location-dot text-danger me-1"></i> <%= task.getViTriPhong() %></div>
                            </td>
                            <td><span class="fw-medium text-secondary">Kỹ thuật</span></td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>"><%= task.getMucDo() %></span></td>
                            <td class="text-muted" style="font-size: 0.9rem;"><%= task.getNgayGui() != null ? sdf.format(task.getNgayGui()) : "" %></td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= "Chờ xử lý".equals(task.getTrangThai()) ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>
                            <td class="pe-4 text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#detailModal<%= task.getSuCoId() %>" title="Xem chi tiết">
                                    <i class="fa-solid fa-eye"></i> Xem
                                </button>
                            </td>
                        </tr>

                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">Bạn chưa gửi báo cáo sự cố nào.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- BIỂU ĐỒ & NHẬT KÝ HOẠT ĐỘNG -->
        <div class="row mb-2 mt-4">

            <!-- Cột trái: Biểu đồ -->
            <div class="col-lg-7 mb-4">
                <div class="card stat-card border-0 shadow-sm rounded-3 h-100">
                    <div class="card-body">
                        <h6 class="fw-bold mb-3 text-center text-dark">Tỷ lệ các loại sự cố đã báo cáo</h6>
                        <div style="position: relative; height: 260px; width: 100%; display: flex; justify-content: center;">
                            <canvas id="incidentChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Cột phải: Cập nhật mới nhất từ CSDL -->
            <div class="col-lg-5 mb-4">
                <div class="card stat-card border-0 shadow-sm rounded-3 p-4 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0 text-dark">Cập nhật mới nhất</h5>
                        <a href="${pageContext.request.contextPath}/student-history" class="text-decoration-none text-muted small">Xem tất cả</a>
                    </div>

                    <%
                        List<model.SuCo> listCapNhat = (List<model.SuCo>) request.getAttribute("listCapNhat");
                        if (listCapNhat != null && !listCapNhat.isEmpty()) {
                            for (model.SuCo moiNhat : listCapNhat) {
                                String badgeColor = "Chờ xử lý".equals(moiNhat.getTrangThai()) ? "warning" : ("Đang xử lý".equals(moiNhat.getTrangThai()) ? "primary" : "success");
                    %>
                    <div class="d-flex align-items-start mb-3 border-bottom pb-2">
                        <div class="bg-primary bg-opacity-10 text-primary p-2 rounded-circle me-3">
                            <i class="fa-solid fa-triangle-exclamation fs-6"></i>
                        </div>
                        <div>
                            <div class="fw-bold text-dark" style="font-size: 0.9rem;">#SC0<%= moiNhat.getSuCoId() %> - <%= moiNhat.getTieuDe() %></div>
                            <div class="text-muted small mt-1">Trạng thái: <span class="badge bg-<%= badgeColor %> <%= "Chờ xử lý".equals(moiNhat.getTrangThai()) ? "text-dark" : "text-white" %>"><%= moiNhat.getTrangThai() %></span></div>
                            <div class="text-muted mt-1" style="font-size: 0.75rem;"><i class="fa-regular fa-clock me-1"></i> Gửi lúc: <%= moiNhat.getNgayGui() != null ? sdf.format(moiNhat.getNgayGui()) : "" %></div>
                        </div>
                    </div>
                    <%      }
                    } else {
                    %>
                    <p class="text-muted text-center my-auto">Chưa có hoạt động cập nhật nào.</p>
                    <% } %>
                </div>
            </div>

        </div>

    </div>
</div>


<!--  MODAL GỬI BÁO CÁO SỰ CỐ  -->
<div class="modal fade" id="reportIssueModal" tabindex="-1" aria-labelledby="reportIssueModalLabel" aria-hidden="true" >
    <div class="modal-dialog modal-dialog-centered modal-lg" >
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold" id="reportIssueModalLabel" ><i class="fa-solid fa-file-signature me-2"></i>Gửi Báo Cáo Sự Cố Mới</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">

                <form action="${pageContext.request.contextPath}/report-issue" method="POST" class="needs-validation" novalidate>

                    <div class="mb-3" >
                        <label for="tieuDe" class="form-label fw-bold">Tiêu đề sự cố <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="tieuDe" name="tieuDe"
                               placeholder="VD: Chập cháy bóng đèn giường số 3..."
                               minlength="10" maxlength="100" required>
                        <div class="invalid-feedback">
                            Vui lòng nhập tiêu đề rõ ràng (ít nhất 10 ký tự).
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="loaiSuCoId" class="form-label fw-bold">Danh mục <span class="text-danger">*</span></label>
                            <select class="form-select" id="loaiSuCoId" name="loaiSuCoId" required>
                                <option value="" selected disabled>-- Chọn loại sự cố --</option>
                                <%
                                    List<model.LoaiSuCo> listLoaiSuCo = (List<model.LoaiSuCo>) request.getAttribute("listLoaiSuCo");
                                    if (listLoaiSuCo != null) {
                                        for (model.LoaiSuCo lsc : listLoaiSuCo) {
                                %>
                                <option value="<%= lsc.getLoaiSuCoId() %>"><%= lsc.getTenLoai() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                            <div class="invalid-feedback">
                                Bạn chưa chọn danh mục sự cố.
                            </div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="mucDo" class="form-label fw-bold">Mức độ <span class="text-danger">*</span></label>
                            <select class="form-select" id="mucDo" name="mucDo" required>
                                <option value="THẤP">Thấp (Có thể chờ vài ngày)</option>
                                <option value="TRUNG BÌNH" selected>Trung bình (Cần sửa sớm)</option>
                                <option value="KHẨN CẤP">Khẩn cấp (Nguy hiểm)</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="moTa" class="form-label fw-bold">Mô tả chi tiết <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="moTa" name="moTa" rows="4"
                                  placeholder="Mô tả chính xác vị trí và tình trạng hư hỏng..."
                                  minlength="20" required></textarea>
                        <div class="invalid-feedback">
                            Vui lòng mô tả chi tiết (ít nhất 20 ký tự) để kỹ thuật viên chuẩn bị đồ nghề.
                        </div>
                    </div>

                    <div class="d-flex justify-content-end">
                        <button type="button" class="btn btn-light border me-2 fw-medium" data-bs-dismiss="modal">Hủy bỏ</button>
                        <button class="btn btn-primary fw-bold px-4" type="submit">Gửi Báo Cáo</button>
                    </div>
                </form>

            </div>
        </div>
    </div>
</div>

<%@ include file="profile_modals.jspf" %>

<!-- VÒNG LẶP TẠO MODAL CHI TIẾT SỰ CỐ -->
<%
    if (recentList != null && !recentList.isEmpty()) {
        for (SuCo task : recentList) {
            String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
            String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
%>
<div class="modal fade" id="detailModal<%= task.getSuCoId() %>" tabindex="-1" aria-hidden="true">
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
                <div class="mb-2"><strong>Ngày báo cáo:</strong> <%= task.getNgayGui() != null ? sdf.format(task.getNgayGui()) : "" %></div>
                <div class="mb-2"><strong>Vị trí:</strong> <%= task.getViTriPhong() %></div>
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

<%@ include file="notice_modal.jspf" %>

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

<!-- Script xử lý Validation của Bootstrap -->
<script>
    (function () {
        'use strict'
        var forms = document.querySelectorAll('.needs-validation')
        Array.prototype.slice.call(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })
    })()
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- Thư viện Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const ctx = document.getElementById('incidentChart').getContext('2d');
        const incidentChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: [
                    <%
                        java.util.Map<String, Integer> map = (java.util.Map<String, Integer>) request.getAttribute("thongKeMap");
                        if (map != null && !map.isEmpty()) {
                            for (String key : map.keySet()) {
                    %>
                    '<%= key %>',
                    <%          }
                            } else {
                    %>
                    'Chưa có dữ liệu',
                    <% } %>
                ],
                datasets: [{
                    data: [
                        <%
                            if (map != null && !map.isEmpty()) {
                                for (Integer val : map.values()) {
                        %>
                        <%= val %>,
                        <%          }
                                } else {
                        %>
                        1,
                        <% } %>
                    ],
                    backgroundColor: [
                        '#36a2eb',
                        '#ffcd56',
                        '#ff6384',
                        '#4bc0c0',
                        '#9966ff',
                        '#ff9f40',
                        '#c9cbcf'
                    ],
                    borderWidth: 1,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            font: { size: 12 },
                            boxWidth: 15
                        }
                    }
                }
            }
        });
    });
</script>
</body>
</html>