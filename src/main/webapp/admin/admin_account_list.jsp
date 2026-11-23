<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.TaiKhoan" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Tài Khoản - Quản Trị Hệ Thống</title>
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
    <a href="${pageContext.request.contextPath}/admin-accounts" class="nav-link active">
        <i class="fa-solid fa-users me-2 w-20px"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin-phong" class="nav-link"><i class="fa-solid fa-building me-2 w-20px"></i> Quản lý phòng/tòa</a>    <a href="${pageContext.request.contextPath}/admin-loai-su-co" class="nav-link"><i class="fa-solid fa-list me-2 w-20px"></i> Danh mục loại sự cố</a>
    <a href="${pageContext.request.contextPath}/admin-statistics" class="nav-link"><i class="fa-solid fa-chart-pie me-2 w-20px"></i> Thống kê</a>

    <div class="sidebar-heading">Hệ thống</div>
    <a href="#" class="nav-link"><i class="fa-solid fa-gear me-2 w-20px"></i> Cài đặt</a>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-danger mt-3 mb-4"><i class="fa-solid fa-right-from-bracket me-2 w-20px"></i> Đăng xuất</a>
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
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4 mt-4">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold text-dark mb-0">
                <i class="fa-solid fa-users text-primary me-2"></i>Quản lý Tài khoản Hệ thống
            </h4>
            <button type="button" class="btn btn-primary fw-semibold shadow-sm"
                    data-bs-toggle="modal" data-bs-target="#createAccountModal">
                <i class="fa-solid fa-user-plus me-1"></i> Cấp tài khoản
            </button>
        </div>
        <%
            String currentRole = request.getParameter("role");
            if (currentRole == null || currentRole.trim().isEmpty()) {
                currentRole = "all";
            }
        %>
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <!-- BỘ LỌC THEO VAI TRÒ -->
            <div class="btn-group shadow-sm" role="group">
                <a href="?role=all" class="btn btn-outline-secondary filter-btn <%= currentRole.equals("all") ? "active" : "" %>">Tất cả tài khoản</a>
                <a href="?role=NHAN_VIEN" class="btn btn-outline-secondary filter-btn <%= currentRole.equals("NHAN_VIEN") ? "active text-primary" : "" %>">Nhân viên kỹ thuật</a>
                <a href="?role=SINH_VIEN" class="btn btn-outline-secondary filter-btn <%= currentRole.equals("SINH_VIEN") ? "active text-success" : "" %>">Sinh viên</a>
            </div>

            <!-- Bộ lọc Tổ phụ trách, Trạng thái & Ô tìm kiếm -->
            <div class="d-flex flex-wrap align-items-center gap-2">
                <select id="teamFilter" class="form-select form-select-sm shadow-sm" style="width: 170px;">
                    <option value="">Tất cả tổ phụ trách</option>
                    <option value="Tổ Bảo An">Tổ Bảo An</option>
                    <option value="Tổ Cơ Sở Vật Chất">Tổ Cơ Sở Vật Chất</option>
                    <option value="Tổ Điện Nước">Tổ Điện Nước</option>
                    <option value="Tổ Mạng & Internet">Tổ Mạng & Internet</option>
                </select>

                <select id="statusFilter" class="form-select form-select-sm shadow-sm" style="width: 155px;">
                    <option value="">Tất cả trạng thái</option>
                    <option value="Hoạt động">Hoạt động</option>
                    <option value="Ngừng hoạt động">Ngừng hoạt động</option>
                </select>

                <div class="input-group input-group-sm shadow-sm" style="width: 270px;">
            <span class="input-group-text bg-white border-end-0 text-muted">
                <i class="fa-solid fa-magnifying-glass"></i>
            </span>
                    <input type="text" id="accountSearchInput" class="form-control border-start-0"
                           placeholder="Tìm mã TK, tên, username, SĐT...">
                </div>
            </div>
        </div>

        <!-- BẢNG DANH SÁCH TÀI KHOẢN -->
        <div class="card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ TK</th>
                            <th class="fw-medium py-3">HỌ VÀ TÊN</th>
                            <th class="fw-medium py-3">TÊN ĐĂNG NHẬP</th>
                            <th class="fw-medium py-3">SỐ ĐIỆN THOẠI</th>
                            <th class="fw-medium py-3">TỔ PHỤ TRÁCH</th>
                            <th class="fw-medium py-3">VAI TRÒ</th>
                            <th class="fw-medium py-3">TRẠNG THÁI</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody id="accountTableBody">
                        <%
                            List<TaiKhoan> listAccounts = (List<TaiKhoan>) request.getAttribute("listAccounts");
                            if (listAccounts != null && !listAccounts.isEmpty()) {
                                for (TaiKhoan tk : listAccounts) {
                                    String badgeRole = "NHAN_VIEN".equals(tk.getVaiTro()) ? "primary" : "success";
                                    String roleName = "NHAN_VIEN".equals(tk.getVaiTro()) ? "Nhân viên" : "Sinh viên";
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary">#TK<%= tk.getTaiKhoanId() %></span></td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(tk.getHoTen() != null ? tk.getHoTen() : "User", "UTF-8") %>&background=random" class="rounded-circle me-2" width="28">
                                    <span class="fw-bold text-dark"><%= tk.getHoTen() %></span>
                                </div>
                            </td>
                            <td><%= tk.getTenDangNhap() %></td>
                            <td>
                                <a href="tel:<%= tk.getSoDienThoai() %>" class="text-decoration-none fw-medium text-primary">
                                    <i class="fa-solid fa-phone fa-sm me-1"></i> <%= tk.getSoDienThoai() %>
                                </a>
                            </td>
                            <td>
                                <% if ("NHAN_VIEN".equals(tk.getVaiTro())) { %>
                                <span class="badge bg-secondary bg-opacity-10 text-dark border"><%= tk.getTenTo() %></span>
                                <% } else { %>
                                <span class="text-muted small">--</span>
                                <% } %>
                            </td>
                            <td>
                                <span class="badge bg-<%= badgeRole %> bg-opacity-10 text-<%= badgeRole %> border border-<%= badgeRole %>"><%= roleName %></span>
                            </td>
                            <td>
                                <% if (tk.isTrangThai()) { %>
                                <span class="badge bg-success">Hoạt động</span>
                                <% } else { %>
                                <span class="badge bg-secondary">Ngừng hoạt động</span>
                                <% } %>
                            </td>
                            <td class="pe-4 text-center">
                                <form action="${pageContext.request.contextPath}/admin-accounts" method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="taiKhoanId" value="<%= tk.getTaiKhoanId() %>">
                                    <input type="hidden" name="role" value="<%= currentRole %>">
                                    <% if (tk.isTrangThai()) { %>
                                    <input type="hidden" name="trangThaiMoi" value="0">
                                    <button type="submit" class="btn btn-sm btn-outline-danger shadow-sm"
                                            onclick="return confirm('Chuyển tài khoản <%= tk.getTenDangNhap() %> sang Ngừng hoạt động (0)?');"
                                            title="Ngừng hoạt động">
                                        <i class="fa-solid fa-ban me-1"></i> Ngừng hoạt động
                                    </button>
                                    <% } else { %>
                                    <input type="hidden" name="trangThaiMoi" value="1">
                                    <button type="submit" class="btn btn-sm btn-outline-success shadow-sm"
                                            onclick="return confirm('Kích hoạt lại tài khoản <%= tk.getTenDangNhap() %> (1)?');"
                                            title="Kích hoạt">
                                        <i class="fa-solid fa-check me-1"></i> Hoạt động
                                    </button>
                                    <% } %>
                                </form>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">Không tìm thấy tài khoản nào phù hợp.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

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
    const searchInput = document.getElementById('accountSearchInput');
    const teamFilter = document.getElementById('teamFilter');
    const statusFilter = document.getElementById('statusFilter');
    const tableBody = document.getElementById('accountTableBody');

    function filterAccounts() {
        const keyword = searchInput.value.trim().toLowerCase();
        const team = teamFilter.value.trim().toLowerCase();
        const status = statusFilter.value.trim().toLowerCase();
        const rows = tableBody.querySelectorAll('tr');

        rows.forEach(row => {
            if (row.cells.length < 7) return; // bỏ qua dòng thông báo trống

            // Lấy dữ liệu các cột: 0=Mã TK, 1=Họ tên, 2=Username, 3=SĐT, 4=Tổ, 6=Trạng thái
            const searchTarget = (
                row.cells[0].innerText + ' ' +
                row.cells[1].innerText + ' ' +
                row.cells[2].innerText + ' ' +
                row.cells[3].innerText
            ).toLowerCase();

            const teamText = row.cells[4].innerText.trim().toLowerCase();
            const statusText = row.cells[6].innerText.trim().toLowerCase();

            const matchKeyword = !keyword || searchTarget.includes(keyword);
            const matchTeam = !team || teamText === team;
            const matchStatus = !status || statusText === status;

            row.style.display = (matchKeyword && matchTeam && matchStatus) ? '' : 'none';
        });
    }

    searchInput.addEventListener('input', filterAccounts);
    teamFilter.addEventListener('change', filterAccounts);
    statusFilter.addEventListener('change', filterAccounts);
</script>

<!-- MODAL CẤP TÀI KHOẢN MỚI -->
<div class="modal fade" id="createAccountModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold">
                    <i class="fa-solid fa-user-plus me-2"></i>Cấp tài khoản mới
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <form action="${pageContext.request.contextPath}/admin-accounts" method="POST">
                <input type="hidden" name="action" value="create">
                <div class="modal-body p-4">

                    <!-- Chọn loại tài khoản (2 dạng) -->
                    <div class="mb-3">
                        <label class="form-label fw-bold">Loại tài khoản <span class="text-danger">*</span></label>
                        <div class="btn-group w-100" role="group">
                            <input type="radio" class="btn-check" name="vaiTro" id="roleStaff" value="NHAN_VIEN" checked>
                            <label class="btn btn-outline-primary fw-medium" for="roleStaff">
                                <i class="fa-solid fa-screwdriver-wrench me-1"></i> Nhân viên kỹ thuật
                            </label>

                            <input type="radio" class="btn-check" name="vaiTro" id="roleStudent" value="SINH_VIEN">
                            <label class="btn btn-outline-success fw-medium" for="roleStudent">
                                <i class="fa-solid fa-user-graduate me-1"></i> Sinh viên
                            </label>
                        </div>
                    </div>

                    <!-- Các trường bắt buộc chung -->
                    <div class="mb-3">
                        <label class="form-label fw-bold">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="hoTen" placeholder="VD: Nguyễn Văn A" required>
                    </div>

                    <div class="row g-2 mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Tên đăng nhập <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="tenDangNhap" placeholder="VD: nv09 hoặc sv51" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Mật khẩu mặc định <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="matKhau" value="123456" required>
                        </div>
                    </div>

                    <!-- Chỉ hiện khi chọn Nhân viên -->
                    <div class="mb-2" id="teamSelectWrapper">
                        <label class="form-label fw-bold">Tổ phụ trách <span class="text-danger">*</span></label>
                        <select class="form-select" name="toId" id="toIdSelect" required>
                            <option value="">-- Chọn tổ kỹ thuật --</option>
                            <option value="1">Tổ Điện Nước</option>
                            <option value="2">Tổ Cơ Sở Vật Chất</option>
                            <option value="3">Tổ Mạng & Internet</option>
                            <option value="4">Tổ Bảo An</option>
                        </select>
                        <div class="form-text">Nhân viên sẽ nhận và xử lý các sự cố thuộc tổ này.</div>
                    </div>

                    <div class="alert alert-light border small text-muted mb-0 mt-3">
                        <i class="fa-solid fa-circle-info text-primary me-1"></i>
                        Số điện thoại và các thông tin cá nhân khác người dùng có thể tự cập nhật sau khi đăng nhập.
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-light border" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary fw-bold px-4">Tạo tài khoản</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const roleStaff = document.getElementById('roleStaff');
    const roleStudent = document.getElementById('roleStudent');
    const teamWrapper = document.getElementById('teamSelectWrapper');
    const toIdSelect = document.getElementById('toIdSelect');

    function toggleTeamField() {
        if (roleStaff.checked) {
            teamWrapper.style.display = 'block';
            toIdSelect.required = true;
        } else {
            teamWrapper.style.display = 'none';
            toIdSelect.required = false;
            toIdSelect.value = '';
        }
    }

    roleStaff.addEventListener('change', toggleTeamField);
    roleStudent.addEventListener('change', toggleTeamField);
</script>

</body>
</html>