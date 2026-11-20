<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="model.Phong" %>
<%@ page import="dao.PhongDAO" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Phòng/Tòa - Quản Trị Hệ Thống</title>
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
        .w-20px {
            width: 22px;
            text-align: center;
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
        .stat-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
            transition: transform 0.2s;
        }
        .filter-btn.active {
            font-weight: bold;
            border-color: #0d6efd;
            color: #0d6efd;
            background-color: #f8f9fa;
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
    <a href="${pageContext.request.contextPath}/admin-home" class="nav-link"><i class="fa-solid fa-chart-line me-2 w-20px"></i> Bảng điều khiển</a>

    <div class="sidebar-heading">Nghiệp vụ</div>
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#createNoticeModal">
        <i class="fa-solid fa-bullhorn me-2 w-20px"></i> Đăng thông báo
    </a>
    <a href="${pageContext.request.contextPath}/admin-incidents" class="nav-link d-flex justify-content-between align-items-center">
        <span><i class="fa-solid fa-triangle-exclamation me-2 w-20px"></i> Quản lý sự cố</span>
        <span class="badge bg-danger rounded-pill">${pending != null ? pending : 0}</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin-accounts" class="nav-link">
        <i class="fa-solid fa-users me-2 w-20px"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin-phong" class="nav-link active">
        <i class="fa-solid fa-building me-2 w-20px"></i> Quản lý phòng/tòa
    </a>
    <a href="${pageContext.request.contextPath}/admin-loai-su-co" class="nav-link">
        <i class="fa-solid fa-list me-2 w-20px"></i> Danh mục loại sự cố
    </a>

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

        <%
            String phongMsg = (String) session.getAttribute("phongMsg");
            String phongMsgType = (String) session.getAttribute("phongMsgType");
            if (phongMsg != null) {
                session.removeAttribute("phongMsg");
                session.removeAttribute("phongMsgType");
        %>
        <div class="alert alert-<%= phongMsgType != null ? phongMsgType : "info" %> alert-dismissible fade show mt-3" role="alert">
            <%= phongMsg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- PAGE HEADER & NÚT THÊM MỚI -->
        <div class="d-flex justify-content-between align-items-center mb-4 mt-4">
            <div>
                <h4 class="fw-bold text-dark mb-1"><i class="fa-solid fa-building text-primary me-2"></i>Quản lý Phòng & Tòa nhà</h4>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Quản lý danh sách phòng, tòa nhà, tầng, tình trạng phòng và sinh viên nội trú.</p>
            </div>
            <button class="btn btn-primary fw-medium shadow-sm px-4" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                <i class="fa-solid fa-plus me-2"></i> Thêm phòng mới
            </button>
        </div>

        <!-- BỘ LỌC TÒA NHÀ & TÌM KIẾM -->
        <%
            String currentBuilding = (String) request.getAttribute("currentBuilding");
            if (currentBuilding == null) currentBuilding = "all";
            List<String> listToaNha = (List<String>) request.getAttribute("listToaNha");
        %>
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <div class="btn-group shadow-sm" role="group">
                <a href="${pageContext.request.contextPath}/admin-phong?building=all"
                   class="btn btn-outline-secondary filter-btn <%= "all".equalsIgnoreCase(currentBuilding) ? "active" : "" %>">Tất cả tòa</a>
                <% if (listToaNha != null) {
                    for (String buildingName : listToaNha) {
                %>
                <a href="${pageContext.request.contextPath}/admin-phong?building=<%= URLEncoder.encode(buildingName, "UTF-8") %>"
                   class="btn btn-outline-secondary filter-btn <%= buildingName.equals(currentBuilding) ? "active" : "" %>"><%= buildingName %></a>
                <%  }
                } %>
            </div>

            <div style="min-width: 260px;">
                <input type="text" id="roomSearchInput" class="form-control bg-white shadow-sm"
                       placeholder="Tìm mã phòng, tầng, loại phòng..." onkeyup="filterRoomTable()">
            </div>
        </div>

        <!-- BẢNG HIỂN THỊ DANH SÁCH PHÒNG -->
        <div class="card stat-card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="roomTable">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ PHÒNG</th>
                            <th class="fw-medium py-3">TÒA NHÀ</th>
                            <th class="fw-medium py-3">TẦNG</th>
                            <th class="fw-medium py-3">LOẠI PHÒNG</th>
                            <th class="fw-medium py-3 text-center">SINH VIÊN Ở</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<Phong> listPhong = (List<Phong>) request.getAttribute("listPhong");
                            PhongDAO phongDaoHelper = new PhongDAO();
                            if (listPhong != null && !listPhong.isEmpty()) {
                                for (Phong p : listPhong) {
                                    String status = p.getTrangThai() != null ? p.getTrangThai() : "";
                                    String badgeStatus = "Đang sử dụng".equalsIgnoreCase(status) ? "primary"
                                            : ("Còn trống".equalsIgnoreCase(status) ? "success" : "warning");
                        %>
                        <tr class="room-row">
                            <td class="ps-4"><span class="fw-bold text-secondary">#P0<%= p.getPhongId() %></span> - <span class="fw-bold text-dark"><%= p.getMaPhong() %></span></td>
                            <td>
                                <span class="badge bg-info bg-opacity-10 text-info border border-info px-2 py-1 fw-medium">
                                    <i class="fa-solid fa-building me-1"></i> <%= p.getToaNha() %>
                                </span>
                            </td>
                            <td>Tầng <%= p.getTang() %></td>
                            <td class="text-muted"><%= p.getLoaiPhong() != null ? p.getLoaiPhong() : "Không có mô tả" %></td>
                            <td class="text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#studentsModal<%= p.getPhongId() %>"
                                        title="Xem danh sách sinh viên trong phòng">
                                    <i class="fa-solid fa-eye"></i>
                                    <span class="badge bg-primary ms-1"><%= p.getSoSinhVien() %></span>
                                </button>
                            </td>
                            <td>
                                <span class="badge bg-<%= badgeStatus %> <%= "warning".equals(badgeStatus) ? "text-dark" : "" %>">
                                    <%= status %>
                                </span>
                            </td>
                            <td class="pe-4 text-center">
                                <button type="button" class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#editRoomModal<%= p.getPhongId() %>" title="Sửa">
                                    <i class="fa-solid fa-pen-to-square"></i> Sửa
                                </button>
                                <form action="${pageContext.request.contextPath}/admin-phong" method="POST" style="display:inline;"
                                      onsubmit="return confirm('Bạn có chắc chắn muốn xóa phòng <%= p.getMaPhong() %> (<%= p.getToaNha() %>) không?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="phongId" value="<%= p.getPhongId() %>">
                                    <input type="hidden" name="building" value="<%= currentBuilding %>">
                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Xóa">
                                        <i class="fa-solid fa-trash"></i> Xóa
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">Chưa có phòng nào trong danh mục.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div> <!-- End container-fluid -->
</div> <!-- End main-content -->

<!-- MODAL THÊM PHÒNG MỚI -->
<div class="modal fade" id="addRoomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin-phong" method="POST">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="building" value="<%= currentBuilding %>">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-plus-circle me-2"></i>Thêm phòng mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4 text-start">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mã phòng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="maPhong" placeholder="VD: P103, P301..." required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tòa nhà <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="toaNha" list="buildingSuggestions"
                               placeholder="Chọn hoặc nhập tên tòa (VD: Tòa A1, Tòa B1)..." required>
                        <datalist id="buildingSuggestions">
                            <option value="Tòa A1">
                            <option value="Tòa A2">
                                    <% if (listToaNha != null) {
                                for (String b : listToaNha) { %>
                            <option value="<%= b %>">
                                    <%  }
                            } %>
                        </datalist>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Tầng <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="tang" min="1" max="50" value="1" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Trạng thái <span class="text-danger">*</span></label>
                            <select class="form-select" name="trangThai" required>
                                <option value="Còn trống">Còn trống</option>
                                <option value="Đang sử dụng">Đang sử dụng</option>
                                <option value="Đang bảo trì">Đang bảo trì</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Loại phòng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="loaiPhong" placeholder="VD: Phòng 6 người, Phòng 8 người..." required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light border px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary fw-bold px-4">Thêm mới</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- VÒNG LẶP TẠO MODAL XEM SINH VIÊN VÀ SỬA CHO TỪNG PHÒNG -->
<%
    if (listPhong != null && !listPhong.isEmpty()) {
        for (Phong p : listPhong) {
            List<String[]> svListModal = phongDaoHelper.getStudentsByPhongId(p.getPhongId());
            String st = p.getTrangThai() != null ? p.getTrangThai() : "";
%>
<div class="modal fade" id="studentsModal<%= p.getPhongId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-users me-2"></i>Sinh viên phòng <%= p.getMaPhong() %> - <%= p.getToaNha() %></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <% if (svListModal != null && !svListModal.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th class="py-2">Mã SV</th>
                            <th class="py-2">Họ và tên</th>
                            <th class="py-2">Lớp / Khoa</th>
                            <th class="py-2">Số điện thoại</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (String[] sv : svListModal) { %>
                        <tr>
                            <td class="fw-bold text-dark"><%= sv[0] %></td>
                            <td class="fw-bold text-dark"><%= sv[1] %></td>
                            <td><%= sv[2] %> - <%= sv[3] %></td>
                            <td>
                                <a href="tel:<%= sv[4] %>" class="text-decoration-none">
                                    <i class="fa-solid fa-phone text-success me-1"></i> <%= sv[4] %>
                                </a>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-4 text-muted bg-light rounded border">
                    <i class="fa-solid fa-door-open fs-4 text-warning mb-2"></i>
                    <p class="mb-0">Hiện chưa có sinh viên nào đăng ký ở phòng này.</p>
                </div>
                <% } %>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editRoomModal<%= p.getPhongId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin-phong" method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="phongId" value="<%= p.getPhongId() %>">
                <input type="hidden" name="building" value="<%= currentBuilding %>">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Cập nhật phòng #P0<%= p.getPhongId() %> - <%= p.getMaPhong() %></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4 text-start">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mã phòng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="maPhong" value="<%= p.getMaPhong() %>" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tòa nhà <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="toaNha" value="<%= p.getToaNha() %>" required>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Tầng <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="tang" min="1" max="50" value="<%= p.getTang() %>" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Trạng thái <span class="text-danger">*</span></label>
                            <select class="form-select" name="trangThai" required>
                                <option value="Còn trống" <%= "Còn trống".equalsIgnoreCase(st) ? "selected" : "" %>>Còn trống</option>
                                <option value="Đang sử dụng" <%= "Đang sử dụng".equalsIgnoreCase(st) ? "selected" : "" %>>Đang sử dụng</option>
                                <option value="Đang bảo trì" <%= "Đang bảo trì".equalsIgnoreCase(st) ? "selected" : "" %>>Đang bảo trì</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Loại phòng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="loaiPhong" value="<%= p.getLoaiPhong() %>" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light border px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary fw-bold px-4">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>
<%
        }
    }
%>

<!-- MODAL ĐĂNG THÔNG BÁO TỪ ADMIN -->
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

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function filterRoomTable() {
        const keyword = document.getElementById('roomSearchInput').value.toLowerCase().trim();
        const rows = document.querySelectorAll('#roomTable tbody tr.room-row');
        rows.forEach(row => {
            const text = row.innerText.toLowerCase();
            row.style.display = text.includes(keyword) ? '' : 'none';
        });
    }
</script>
</body>
</html>