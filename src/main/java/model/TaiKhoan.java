package model;

public class TaiKhoan {
    private int taiKhoanId;
    private String tenDangNhap;
    private String matKhau;
    private String hoTen;
    private String vaiTro;
    private boolean trangThai;

    public TaiKhoan() {}

    public TaiKhoan(int taiKhoanId, String tenDangNhap, String matKhau, String hoTen, String vaiTro, boolean trangThai) {
        this.taiKhoanId = taiKhoanId;
        this.tenDangNhap = tenDangNhap;
        this.matKhau = matKhau;
        this.hoTen = hoTen;
        this.vaiTro = vaiTro;
        this.trangThai = trangThai;
    }

    public String getMatKhau() {
        return matKhau;
    }

    public void setMatKhau(String matKhau) {
        this.matKhau = matKhau;
    }

    public int getTaiKhoanId() {
        return taiKhoanId;
    }

    public void setTaiKhoanId(int taiKhoanId) {
        this.taiKhoanId = taiKhoanId;
    }

    public String getTenDangNhap() {
        return tenDangNhap;
    }

    public void setTenDangNhap(String tenDangNhap) {
        this.tenDangNhap = tenDangNhap;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public String getVaiTro() {
        return vaiTro;
    }

    public void setVaiTro(String vaiTro) {
        this.vaiTro = vaiTro;
    }

    public boolean isTrangThai() {
        return trangThai;
    }

    public void setTrangThai(boolean trangThai) {
        this.trangThai = trangThai;
    }
// Bạn hãy nhấn Alt + Insert (hoặc chuột phải chọn Generate)
    // -> Chọn "Getter and Setter" -> Bôi đen tất cả các biến -> Nhấn OK để IntelliJ tự sinh code.
}