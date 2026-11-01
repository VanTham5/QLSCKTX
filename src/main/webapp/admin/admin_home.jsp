<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Quản Trị - KTX Support</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            overflow-x: hidden;
        }
        /* Sidebar */
        .sidebar {
            width: 260px;
            background-color: #343a40;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
        }
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
            padding-bottom: 30px;
        }
        .sidebar .nav-link {
            color: #c2c7d0;
            padding: 12px 20px;
            font-weight: 500;
            border-left: 3px solid transparent;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            background-color: rgba(255,255,255,0.1);
            color: #ffffff;
            border-left: 3px solid #0d6efd;
        }
        .sidebar-heading {
            font-size: 0.75rem;
            text-transform: uppercase;
            color: #6c757d;
            font-weight: bold;
            padding: 10px 20px;
            margin-top: 15px;
        }
        .w-20px { width: 22px; text-align: center; }

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
        .stat-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-3px); }
        .icon-box {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
    </style>
</head>
<body>

<!-- SIDEBAR ADMIN -->
<div class="sidebar d-flex flex-column" style="overflow-y: auto;">
    <div class="d-flex align-items-center p-3 border-bottom border-secondary" style="height: 60px;">
        <i class="fa-solid fa-server fs-4 text-primary me-2"></i>
        <h5 class="mb-0 fw-bold text-white" style="font-size: 1.1rem;">QUẢN TRỊ HỆ THỐNG</h5>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="admin_home.jsp" class="nav-link active"><i class="fa-solid fa-chart-line me-2 w-20px"></i> Bảng điều khiển</a>

    <div class="sidebar-heading">Nghiệp vụ</div>
    <a href="#" class="nav-link d-flex justify-content-between align-items-center">
        <span><i class="fa-solid fa-triangle-exclamation me-2 w-20px"></i> Quản lý sự cố</span>
        <span class="badge bg-danger rounded-pill">${pending != null ? pending : 0}</span>
    </a>
    <a href="#" class="nav-link"><i class="fa-solid fa-users me-2 w-20px"></i> Quản lý tài khoản</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-building me-2 w-20px"></i> Quản lý phòng/tòa</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-list me-2 w-20px"></i> Danh mục loại sự cố</a>

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
                <li><a class="dropdown-item" href="#">Cấu hình tài khoản</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/login.jsp">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4">

        <!-- PAGE HEADER -->
        <div class="d-flex justify-content-between align-items-center mb-4 mt-4">
            <div>
                <h4 class="fw-bold text-dark mb-1">Bảng điều khiển Trung tâm</h4>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Thống kê tình hình hoạt động của toàn bộ Ký túc xá.</p>
            </div>
            <button class="btn btn-primary fw-medium shadow-sm px-4">
                <i class="fa-solid fa-file-export me-2"></i> Xuất báo cáo Excel
            </button>
        </div>

        <!-- THỐNG KÊ TỔNG QUAN -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-primary bg-opacity-10 border border-primary border-opacity-25">
                    <div class="icon-box bg-primary text-white me-3 shadow-sm">
                        <i class="fa-solid fa-layer-group"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-primary">${total != null ? total : 0}</h3>
                        <span class="text-muted small fw-medium">Tổng sự cố tháng này</span>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-danger bg-opacity-10 border border-danger border-opacity-25">
                    <div class="icon-box bg-danger text-white me-3 shadow-sm">
                        <i class="fa-solid fa-user-clock"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-danger">${pending != null ? pending : 0}</h3>
                        <span class="text-muted small fw-medium">Chờ phân công xử lý</span>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-warning bg-opacity-10 border border-warning border-opacity-25">
                    <div class="icon-box bg-warning text-dark me-3 shadow-sm">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-dark">${processing != null ? processing : 0}</h3>
                        <span class="text-muted small fw-medium">Đang tiến hành sửa chữa</span>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center bg-success bg-opacity-10 border border-success border-opacity-25">
                    <div class="icon-box bg-success text-white me-3 shadow-sm">
                        <i class="fa-solid fa-users"></i>
                    </div>
                    <div>
                        <h3 class="fw-bold mb-0 text-success">${totalStudents != null ? totalStudents : 0}</h3>
                        <span class="text-muted small fw-medium">Tổng sinh viên nội trú</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG THEO DÕI SỰ CỐ TOÀN HỆ THỐNG -->
        <div class="d-flex justify-content-between align-items-center mb-3 mt-5">
            <h5 class="fw-bold mb-0">Sự cố chờ điều phối & Phân công</h5>
            <div class="input-group" style="width: 300px;">
                <input type="text" class="form-control form-control-sm" placeholder="Tìm theo mã SC, tên SV...">
                <button class="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-magnifying-glass"></i></button>
            </div>
        </div>

        <div class="card stat-card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ SC</th>
                            <th class="fw-medium py-3">TIÊU ĐỀ SỰ CỐ</th>
                            <th class="fw-medium py-3">NGƯỜI BÁO CÁO</th>
                            <th class="fw-medium py-3">VỊ TRÍ</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="fw-medium py-3 text-center">CHI TIẾT</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<SuCo> listSuCo = (List<SuCo>) request.getAttribute("listSuCo");
                            if (listSuCo != null && !listSuCo.isEmpty()) {
                                for (SuCo task : listSuCo) {
                                    String badgeMucDo = "KHẨN CẤP".equals(task.getMucDo()) ? "danger" : ("TRUNG BÌNH".equals(task.getMucDo()) ? "warning" : "success");
                                    String badgeTrangThai = "Chờ xử lý".equals(task.getTrangThai()) ? "warning" : ("Đang xử lý".equals(task.getTrangThai()) ? "primary" : "success");
                                    String tenNguoiGui = task.getTenNguoiGui() != null ? task.getTenNguoiGui() : "Không rõ";
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
                            <td><span class="fw-medium text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> <%= task.getViTriPhong() %></span></td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>"><%= task.getMucDo() %></span></td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= "Chờ xử lý".equals(task.getTrangThai()) ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>
                            <td class="text-center">
                                <button class="btn btn-sm btn-light text-primary border" title="Xem chi tiết"><i class="fa-solid fa-eye"></i></button>
                            </td>
                            <td class="pe-4 text-center">
                                <button class="btn btn-sm btn-outline-primary shadow-sm" title="Phân công / Cập nhật">
                                    <i class="fa-solid fa-pen-to-square"></i> Cập nhật
                                </button>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Hệ thống chưa có sự cố nào.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div> <!-- End container-fluid -->
</div> <!-- End main-content -->

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>