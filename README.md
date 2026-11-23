# Hệ Thống Quản Lý và Xử Lý Sự Cố Ký Túc Xá (KTX Support)

Website hỗ trợ sinh viên báo cáo sự cố cơ sở vật chất tại ký túc xá, giúp ban quản lý điều phối nhân viên kỹ thuật tiếp nhận, xử lý và theo dõi tiến độ theo thời gian thực. Dự án được xây dựng theo kiến trúc **Client–Server** áp dụng mô hình **MVC**.

---

## Tính năng chính

### 1. Chức năng chung
- **Xác thực tài khoản:** Đăng nhập, đăng ký tài khoản sinh viên, đăng xuất.
- **Quản lý cá nhân:** Cập nhật thông tin hồ sơ và đổi mật khẩu.
- **Bảo mật phiên làm việc:** Tích hợp `NoCacheFilter` ngăn chặn truy cập lại trang nội bộ sau khi đăng xuất.

### 2. Phân hệ Sinh viên (Student)
- **Trang chủ & Thông báo:** Xem các thông báo chung và lịch bảo trì từ ban quản lý.
- **Báo cáo sự cố:** Gửi yêu cầu báo hỏng (chọn phòng, loại sự cố, mô tả chi tiết).
- **Lịch sử báo cáo:** Theo dõi danh sách sự cố đã gửi, lọc/tìm kiếm và xem trạng thái xử lý.

### 3. Phân hệ Nhân viên kỹ thuật (Employee)
- **Quản lý công việc:** Xem danh sách các sự cố được phân công xử lý.
- **Cập nhật trạng thái:** Cập nhật tiến độ xử lý sự cố (đang xử lý, hoàn thành...).
- **Thông báo bảo trì:** Tạo thông báo bảo trì hệ thống/phòng ốc.
- **Lịch sử xử lý:** Tra cứu lại các sự cố đã tiếp nhận và hoàn thành.

### 4. Phân hệ Quản trị viên (Admin)
- **Quản lý sự cố & Điều phối:** Xem toàn bộ sự cố trong hệ thống và phân công (`Assign Task`) cho nhân viên kỹ thuật.
- **Quản lý danh mục:** Thêm, sửa, xóa **Phòng** và **Loại sự cố**.
- **Quản lý tài khoản:** Quản lý danh sách tài khoản sinh viên và nhân viên.
- **Quản lý thông báo:** Tạo và phát hành thông báo tới người dùng.
- **Thống kê báo cáo:** Theo dõi số liệu tổng quan về tình hình sự cố tại ký túc xá.

---

## Công nghệ sử dụng

- **Backend:** Java (Servlet, JSP, JDBC)
- **Frontend:** HTML5, CSS3, Bootstrap 5, JavaScript
- **Cơ sở dữ liệu:** MySQL
- **Web Server:** Apache Tomcat 11
- **Quản lý mã nguồn:** Git & GitHub

---

## Cấu trúc thư mục

```text
src/
└── main/
    ├── java/
    │   ├── context/       # Cấu hình kết nối CSDL (DBContext.java)
    │   ├── controller/    # Các Servlet xử lý luồng cho Admin, Employee, Student & Auth
    │   ├── dao/           # Lớp truy xuất dữ liệu (SuCoDAO, TaiKhoanDAO, PhongDAO, ...)
    │   ├── filter/        # Bộ lọc request (NoCacheFilter.java)
    │   ├── model/         # Các đối tượng thực thể (SuCo, TaiKhoan, Phong, LoaiSuCo, ThongBao)
    │   └── test/          # Kiểm thử tầng DAO (SuCoDAOTest.java)
    └── webapp/
        ├── admin/         # Giao diện JSP cho Quản trị viên
        ├── employee/      # Giao diện JSP cho Nhân viên kỹ thuật
        ├── student/       # Giao diện JSP & các modal cho Sinh viên
        ├── WEB-INF/       # Cấu hình web.xml và các thành phần giao diện dùng chung (.jspf)
        ├── index.jsp
        ├── login.jsp
        └── register.jsp
