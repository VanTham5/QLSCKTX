<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SuCo" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Nhân Viên - KTX Support</title>
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
        /* Sidebar Styles (Đã bỏ shadow, dùng border liền mạch) */
        .sidebar {
            width: 260px;
            background-color: #ffffff;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            border-right: 1px solid #e0e0e0;
            z-index: 1000;
        }
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
            padding-bottom: 30px;
        }
        .sidebar .nav-link {
            color: #4b5563;
            padding: 12px 20px;
            font-weight: 500;
            border-left: 3px solid transparent;
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
        }
        .w-20px {
            width: 22px;
            text-align: center;
        }
        /* Top Header (Đã ghim cố định) */
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
        /* Stat Cards */
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
        }
    </style>
</head>
<body>

<!-- SIDEBAR NHÂN VIÊN -->
<div class="sidebar d-flex flex-column" style="overflow-y: auto;">
    <div class="d-flex align-items-center p-3" style="height: 60px; border-bottom: 1px solid #e0e0e0;">
        <i class="fa-solid fa-screwdriver-wrench fs-4 text-primary me-2"></i>
        <h5 class="mb-0 fw-bold text-dark" style="font-size: 1.1rem;">TỔ KỸ THUẬT</h5>
    </div>

    <div class="sidebar-heading">Tổng quan</div>
    <a href="employee_home.jsp" class="nav-link active"><i class="fa-solid fa-chart-pie me-2 w-20px"></i> Bảng điều khiển</a>

    <div class="sidebar-heading">Quản lý công việc</div>
    <a href="#" class="nav-link d-flex justify-content-between align-items-center">
        <span><i class="fa-solid fa-clipboard-list me-2 w-20px"></i> Chờ tiếp nhận</span>
        <span class="badge bg-danger rounded-pill">${pending}</span>
    </a>
    <a href="#" class="nav-link"><i class="fa-solid fa-person-digging me-2 w-20px"></i> Đang xử lý</a>
    <a href="#" class="nav-link"><i class="fa-solid fa-clock-rotate-left me-2 w-20px"></i> Lịch sử công việc</a>

    <div class="sidebar-heading">Tài khoản</div>
    <a href="#" class="nav-link"><i class="fa-regular fa-user me-2 w-20px"></i> Thông tin cá nhân</a>
    <a href="${pageContext.request.contextPath}/login.jsp" class="nav-link text-danger mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
</div>

<!-- MAIN CONTENT -->
<div class="main-content">

    <!-- HEADER TOP -->
    <div class="top-header">
        <div class="dropdown">
            <a href="#" class="d-flex align-items-center text-decoration-none text-dark" data-bs-toggle="dropdown">
                <img src="https://ui-avatars.com/api/?name=${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'NV'}&background=random" alt="Avatar" width="32" height="32" class="rounded-circle me-2">
                <span class="fw-bold">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Trần Văn Kỹ Thuật'}</span>
                <i class="fa-solid fa-chevron-down ms-2" style="font-size: 12px;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item" href="#">Hồ sơ nhân viên</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/login.jsp">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4">

        <!-- PAGE HEADER -->
        <div class="d-flex justify-content-between align-items-center mb-4 mt-4">
            <div>
                <h4 class="fw-bold text-dark mb-1">Bảng điều khiển công việc</h4>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">
                    Xin chào KTV <strong class="text-primary">${not empty sessionScope.acc ? sessionScope.acc.hoTen : 'Trần Văn Kỹ Thuật'}</strong>. Khu vực phụ trách: <strong>Tòa A1, A2</strong>.
                </p>
            </div>
            <button class="btn btn-outline-primary fw-medium shadow-sm rounded-pill px-4">
                <i class="fa-solid fa-print me-2"></i> In báo cáo ngày
            </button>
        </div>

        <!-- THỐNG KÊ NHANH CỦA NHÂN VIÊN -->
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center" style="border-left: 4px solid #ffc107;">
                    <div class="icon-box bg-warning bg-opacity-10 text-warning me-3">
                        <i class="fa-solid fa-clipboard-question"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">${pending != null ? pending : 0}</h4>
                        <span class="text-muted small">Sự cố chờ tiếp nhận</span>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center" style="border-left: 4px solid #0d6efd;">
                    <div class="icon-box bg-primary bg-opacity-10 text-primary me-3">
                        <i class="fa-solid fa-person-digging"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">${processing != null ? processing : 0}</h4>
                        <span class="text-muted small">Công việc đang xử lý</span>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stat-card h-100 p-3 d-flex flex-row align-items-center" style="border-left: 4px solid #198754;">
                    <div class="icon-box bg-success bg-opacity-10 text-success me-3">
                        <i class="fa-solid fa-check-double"></i>
                    </div>
                    <div>
                        <h4 class="fw-bold mb-0">${done != null ? done : 0}</h4>
                        <span class="text-muted small">Đã hoàn thành (Tháng này)</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG CÔNG VIỆC CẦN XỬ LÝ NGAY -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="fw-bold mb-0">Danh sách việc cần làm</h5>
            <div class="btn-group">
                <button type="button" class="btn btn-sm btn-outline-secondary active">Tất cả</button>
                <button type="button" class="btn btn-sm btn-outline-secondary">Khẩn cấp</button>
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
                            <th class="fw-medium py-3">VỊ TRÍ</th>
                            <th class="fw-medium py-3">MỨC ĐỘ</th>
                            <th class="fw-medium py-3">SĐT SINH VIÊN</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="fw-medium py-3 text-center">CHI TIẾT</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            // Hứng danh sách từ Servlet gửi sang
                            List<SuCo> listSuCo = (List<SuCo>) request.getAttribute("listSuCo");

                            if (listSuCo != null && !listSuCo.isEmpty()) {
                                for (SuCo task : listSuCo) {
                                    // Cài đặt màu sắc badge tự động theo dữ liệu
                                    String badgeMucDo = task.getMucDo().equals("KHẨN CẤP") ? "danger" : (task.getMucDo().equals("TRUNG BÌNH") ? "warning" : "success");
                                    String badgeTrangThai = task.getTrangThai().equals("Chờ xử lý") ? "warning" : (task.getTrangThai().equals("Đang xử lý") ? "primary" : "success");
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary">#SC0<%= task.getSuCoId() %></span></td>
                            <td>
                                <div class="fw-bold text-dark"><%= task.getTieuDe() %></div>
                                <div class="text-muted" style="font-size: 0.8rem;">Gửi lúc: <%= task.getNgayGui() %></div>
                            </td>
                            <td><span class="fw-medium text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> <%= task.getViTriPhong() %></span></td>
                            <td><span class="badge bg-<%= badgeMucDo %> bg-opacity-10 text-<%= badgeMucDo %> border border-<%= badgeMucDo %>"><%= task.getMucDo() %></span></td>
                            <td>
                                <a href="tel:<%= task.getSoDienThoai().replace(".", "") %>" class="text-decoration-none fw-medium text-primary">
                                    <i class="fa-solid fa-phone fa-sm me-1"></i> <%= task.getSoDienThoai() %>
                                </a>
                            </td>
                            <td><span class="badge bg-<%= badgeTrangThai %> <%= task.getTrangThai().equals("Chờ xử lý") ? "text-dark" : "text-white" %>"><%= task.getTrangThai() %></span></td>

                            <td class="text-center">
                                <button class="btn btn-sm btn-light text-primary border" title="Xem chi tiết công việc">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </td>

                            <td class="pe-4 text-center">
                                <% if (task.getTrangThai().equals("Chờ xử lý")) { %>
                                <!-- Form để bấm "Nhận việc" (Sẽ gửi lên UpdateStatusServlet) -->
                                <form action="${pageContext.request.contextPath}/update-status" method="post" style="display:inline;">
                                    <input type="hidden" name="suCoId" value="<%= task.getSuCoId() %>">
                                    <input type="hidden" name="trangThaiMoi" value="Đang xử lý">
                                    <button type="submit" class="btn btn-sm btn-success shadow-sm">
                                        <i class="fa-solid fa-hand-holding-hand me-1"></i> Nhận việc
                                    </button>
                                </form>
                                <% } else if (task.getTrangThai().equals("Đang xử lý")) { %>
                                <!-- Form để bấm "Xong" -->
                                <form action="${pageContext.request.contextPath}/update-status" method="post" style="display:inline;">
                                    <input type="hidden" name="suCoId" value="<%= task.getSuCoId() %>">
                                    <input type="hidden" name="trangThaiMoi" value="Đã hoàn thành">
                                    <button type="submit" class="btn btn-sm btn-primary shadow-sm">
                                        <i class="fa-solid fa-check me-1"></i> Xong
                                    </button>
                                </form>
                                <% } else { %>
                                <span class="text-success fw-bold"><i class="fa-solid fa-check-double"></i></span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Không có sự cố nào đang chờ xử lý.</td>
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