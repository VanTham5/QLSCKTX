<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.LoaiSuCo" %>
<%@ page import="dao.SuCoDAO" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh mục loại sự cố - Quản Trị KTX</title>
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
    <a href="#" class="nav-link" data-bs-toggle="modal" data-bs-target="#createNoticeModal">
        <i class="fa-solid fa-bullhorn me-2 w-20px"></i> Đăng thông báo
    </a>
    <a href="${pageContext.request.contextPath}/admin-incidents" class="nav-link">
        <span><i class="fa-solid fa-triangle-exclamation me-2 w-20px"></i> Quản lý sự cố</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin-accounts" class="nav-link">
        <i class="fa-solid fa-users me-2 w-20px"></i> Quản lý tài khoản
    </a>
    <a href="${pageContext.request.contextPath}/admin-phong" class="nav-link"><i class="fa-solid fa-building me-2 w-20px"></i> Quản lý phòng/tòa</a>    <a href="${pageContext.request.contextPath}/admin-loai-su-co" class="nav-link active"><i class="fa-solid fa-list me-2 w-20px"></i> Danh mục loại sự cố</a>

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
                <li><a class="dropdown-item" href="#">Cấu hình tài khoản</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
            </ul>
        </div>
    </div>

    <div class="container-fluid px-4">

        <!-- PAGE HEADER & NÚT THÊM MỚI -->
        <div class="d-flex justify-content-between align-items-center mb-4 mt-4">
            <div>
                <h4 class="fw-bold text-dark mb-1">Quản lý Danh mục loại sự cố</h4>
                <p class="text-muted mb-0" style="font-size: 0.9rem;">Thiết lập phân loại sự cố và tổ chuyên môn phụ trách.</p>
            </div>
            <button class="btn btn-primary fw-medium shadow-sm px-4" data-bs-toggle="modal" data-bs-target="#addModal">
                <i class="fa-solid fa-plus me-2"></i> Thêm loại sự cố mới
            </button>
        </div>

        <!-- BẢNG HIỂN THỊ DANH MỤC -->
        <div class="card stat-card border-0 shadow-sm rounded-3 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light text-muted" style="font-size: 0.85rem;">
                        <tr>
                            <th class="ps-4 fw-medium py-3">MÃ LOẠI</th>
                            <th class="fw-medium py-3">TÊN LOẠI SỰ CỐ</th>
                            <th class="fw-medium py-3">TỔ PHỤ TRÁCH</th>
                            <th class="fw-medium py-3">MÔ TẢ</th>
                            <th class="fw-medium py-3 text-center">NHÂN SỰ</th>
                            <th class="pe-4 fw-medium py-3 text-center">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<LoaiSuCo> list = (List<LoaiSuCo>) request.getAttribute("listLoaiSuCo");
                            SuCoDAO daoForStaff = new SuCoDAO();
                            if (list != null && !list.isEmpty()) {
                                for (LoaiSuCo item : list) {
                                    List<model.TaiKhoan> listStaffOfTeam = daoForStaff.getStaffByTeam(item.getToId());
                        %>
                        <tr>
                            <td class="ps-4"><span class="fw-bold text-secondary">#LSC0<%= item.getLoaiSuCoId() %></span></td>
                            <td class="fw-bold text-dark"><%= item.getTenLoai() %></td>
                            <td>
                                <span class="badge bg-info bg-opacity-10 text-info border border-info px-2 py-1 fw-medium">
                                    <i class="fa-solid fa-screwdriver-wrench me-1"></i> <%= item.getTenTo() %>
                                </span>
                            </td>
                            <td class="text-muted"><%= item.getMoTota() != null ? item.getMoTota() : "Không có mô tả" %></td>

                            <!-- Cột icon con mắt xem nhân sự -->
                            <td class="text-center">
                                <button type="button" class="btn btn-sm btn-light text-primary border"
                                        data-bs-toggle="modal" data-bs-target="#staffModal<%= item.getLoaiSuCoId() %>"
                                        title="Xem danh sách nhân sự thuộc tổ">
                                    <i class="fa-solid fa-eye"></i> <span class="badge bg-primary ms-1"><%= listStaffOfTeam != null ? listStaffOfTeam.size() : 0 %></span>
                                </button>
                            </td>

                            <td class="pe-4 text-center">
                                <button type="button" class="btn btn-sm btn-outline-primary me-1"
                                        data-bs-toggle="modal" data-bs-target="#editModal<%= item.getLoaiSuCoId() %>" title="Sửa">
                                    <i class="fa-solid fa-pen-to-square"></i> Sửa
                                </button>
                                <a href="${pageContext.request.contextPath}/admin-loai-su-co?action=delete&id=<%= item.getLoaiSuCoId() %>"
                                   class="btn btn-sm btn-outline-danger"
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa loại sự cố này không?');" title="Xóa">
                                    <i class="fa-solid fa-trash"></i> Xóa
                                </a>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="6" class="text-center py-4 text-muted">Chưa có loại sự cố nào trong danh mục.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div> <!-- End container-fluid -->
</div> <!-- End main-content -->

<!-- MODAL THÊM LOẠI SỰ CỐ MỚI -->
<div class="modal fade" id="addModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin-loai-su-co" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-plus-circle me-2"></i>Thêm loại sự cố mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4 text-start">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tên loại sự cố <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="tenLoai" placeholder="VD: Hư hỏng hệ thống mạng..." required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tổ chuyên môn phụ trách <span class="text-danger">*</span></label>
                        <select class="form-select" name="toId" required>
                            <option value="" selected disabled>-- Chọn tổ kỹ thuật --</option>
                            <option value="1">Tổ Điện Nước</option>
                            <option value="2">Tổ Cơ Sở Vật Chất</option>
                            <option value="3">Tổ Mạng & Internet</option>
                            <option value="4">Tổ Bảo An</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mô tả chi tiết</label>
                        <textarea class="form-control" name="moTa" rows="3" placeholder="Nhập mô tả chi tiết..."></textarea>
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

<!-- VÒNG LẶP TẠO MODAL XEM NHÂN SỰ CHO TỪNG TỔ -->
<%
    if (list != null && !list.isEmpty()) {
        for (LoaiSuCo item : list) {
            SuCoDAO sDaoModal = new SuCoDAO();
            List<model.TaiKhoan> listStaffModal = sDaoModal.getStaffByTeam(item.getToId());
%>
<div class="modal fade" id="staffModal<%= item.getLoaiSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-users-gear me-2"></i>Nhân sự thuộc <%= item.getTenTo() %></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <p class="text-muted small mb-3">Danh sách kỹ thuật viên phụ trách tiếp nhận và xử lý mảng: <strong class="text-dark"><%= item.getTenLoai() %></strong></p>

                <% if (listStaffModal != null && !listStaffModal.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-bordered align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th class="py-2">Họ và Tên</th>
                            <th class="py-2">Số điện thoại</th>
                            <th class="py-2 text-center">Trạng thái</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (model.TaiKhoan staff : listStaffModal) { %>
                        <tr>
                            <td class="fw-bold text-dark"><%= staff.getHoTen() %></td>
                            <td>
                                <a href="tel:<%= staff.getSoDienThoai() %>" class="text-decoration-none">
                                    <i class="fa-solid fa-phone text-success me-1"></i> <%= staff.getSoDienThoai() != null ? staff.getSoDienThoai() : "Chưa cập nhật" %>
                                </a>
                            </td>
                            <td class="text-center">
                                <span class="badge bg-success bg-opacity-10 text-success border border-success px-2 py-1">Đang trực</span>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-4 text-muted bg-light rounded border">
                    <i class="fa-solid fa-triangle-exclamation fs-4 text-warning mb-2"></i>
                    <p class="mb-0">Chưa có nhân viên nào được phân công vào tổ này.</p>
                </div>
                <% } %>
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

<!-- VÒNG LẶP TẠO MODAL SỬA CHO TỪNG DÒNG -->
<%
    if (list != null && !list.isEmpty()) {
        for (LoaiSuCo item : list) {
%>
<div class="modal fade" id="editModal<%= item.getLoaiSuCoId() %>" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin-loai-su-co" method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" value="<%= item.getLoaiSuCoId() %>">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Cập nhật loại sự cố #LSC0<%= item.getLoaiSuCoId() %></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4 text-start">
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tên loại sự cố <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="tenLoai" value="<%= item.getTenLoai() %>" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tổ chuyên môn phụ trách <span class="text-danger">*</span></label>
                        <select class="form-select" name="toId" required>
                            <option value="1" <%= item.getToId() == 1 ? "selected" : "" %>>Tổ Điện Nước</option>
                            <option value="2" <%= item.getToId() == 2 ? "selected" : "" %>>Tổ Cơ Sở Vật Chất</option>
                            <option value="3" <%= item.getToId() == 3 ? "selected" : "" %>>Tổ Mạng & Internet</option>
                            <option value="4" <%= item.getToId() == 4 ? "selected" : "" %>>Tổ Bảo An</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mô tả chi tiết</label>
                        <textarea class="form-control" name="moTa" rows="3"><%= item.getMoTota() != null ? item.getMoTota() : "" %></textarea>
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
</body>
</html>