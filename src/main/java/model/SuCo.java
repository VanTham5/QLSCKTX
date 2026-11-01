package model;

import java.sql.Timestamp;

public class SuCo {
    private int suCoId;
    private int sinhVienId;
    private int phongId;
    private int loaiSuCoId;
    private String tieuDe;
    private String moTa;
    private String mucDo;
    private String trangThai;
    private Timestamp ngayGui;
    private Timestamp ngayCapNhat;
    private int nhanVienId;

    // Các trường phụ trợ (dùng để hiển thị lên giao diện sau khi JOIN bảng)
    private String tenNguoiGui;
    private String soDienThoai;
    private String viTriPhong; // Ví dụ: "Phòng P304 - Tòa A1"
    private String tenLoaiSuCo;

    public SuCo() {
    }

    // --- GETTER & SETTER ---
    public int getSuCoId() { return suCoId; }
    public void setSuCoId(int suCoId) { this.suCoId = suCoId; }

    public int getSinhVienId() { return sinhVienId; }
    public void setSinhVienId(int sinhVienId) { this.sinhVienId = sinhVienId; }

    public int getPhongId() { return phongId; }
    public void setPhongId(int phongId) { this.phongId = phongId; }

    public int getLoaiSuCoId() { return loaiSuCoId; }
    public void setLoaiSuCoId(int loaiSuCoId) { this.loaiSuCoId = loaiSuCoId; }

    public String getTieuDe() { return tieuDe; }
    public void setTieuDe(String tieuDe) { this.tieuDe = tieuDe; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getMucDo() { return mucDo; }
    public void setMucDo(String mucDo) { this.mucDo = mucDo; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public Timestamp getNgayGui() { return ngayGui; }
    public void setNgayGui(Timestamp ngayGui) { this.ngayGui = ngayGui; }

    public Timestamp getNgayCapNhat() { return ngayCapNhat; }
    public void setNgayCapNhat(Timestamp ngayCapNhat) { this.ngayCapNhat = ngayCapNhat; }

    public int getNhanVienId() { return nhanVienId; }
    public void setNhanVienId(int nhanVienId) { this.nhanVienId = nhanVienId; }

    public String getTenNguoiGui() { return tenNguoiGui; }
    public void setTenNguoiGui(String tenNguoiGui) { this.tenNguoiGui = tenNguoiGui; }

    public String getSoDienThoai() { return soDienThoai; }
    public void setSoDienThoai(String soDienThoai) { this.soDienThoai = soDienThoai; }

    public String getViTriPhong() { return viTriPhong; }
    public void setViTriPhong(String viTriPhong) { this.viTriPhong = viTriPhong; }

    public String getTenLoaiSuCo() { return tenLoaiSuCo; }
    public void setTenLoaiSuCo(String tenLoaiSuCo) { this.tenLoaiSuCo = tenLoaiSuCo; }
}