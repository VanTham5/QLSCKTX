package model;

public class SuCo {
    private String maSC;       // VD: #SC005
    private String tieuDe;
    private String danhMuc;    // Điện, Nước...
    private String viTri;      // Phòng 304 - Tòa A1
    private String mucDo;      // THẤP, TRUNG BÌNH, KHẨN CẤP
    private String ngayGui;    // Đã format dd/MM/yyyy
    private String trangThai;  // Chờ xử lý, Đang xử lý...

    public SuCo(String maSC, String tieuDe, String danhMuc, String viTri, String mucDo, String ngayGui, String trangThai) {
        this.maSC = maSC;
        this.tieuDe = tieuDe;
        this.danhMuc = danhMuc;
        this.viTri = viTri;
        this.mucDo = mucDo;
        this.ngayGui = ngayGui;
        this.trangThai = trangThai;
    }

    // Bạn hãy nhấn Alt + Insert -> Getter để tạo các hàm get...() cho 7 biến này nhé
    public String getMaSC() { return maSC; }
    public String getTieuDe() { return tieuDe; }
    public String getDanhMuc() { return danhMuc; }
    public String getViTri() { return viTri; }
    public String getMucDo() { return mucDo; }
    public String getNgayGui() { return ngayGui; }
    public String getTrangThai() { return trangThai; }
}