package model;

public class LoaiSuCo {
    private int loaiSuCoId;
    private String tenLoai;
    private int toId;
    private String tenTo; // Tên tổ phụ trách (join từ bảng to_nhan_vien)
    private String moTota; // hoặc moTa

    public LoaiSuCo() {
    }

    public LoaiSuCo(int loaiSuCoId, String tenLoai, int toId, String tenTo, String moTota) {
        this.loaiSuCoId = loaiSuCoId;
        this.tenLoai = tenLoai;
        this.toId = toId;
        this.tenTo = tenTo;
        this.moTota = moTota;
    }

    public int getLoaiSuCoId() { return loaiSuCoId; }
    public void setLoaiSuCoId(int loaiSuCoId) { this.loaiSuCoId = loaiSuCoId; }

    public String getTenLoai() { return tenLoai; }
    public void setTenLoai(String tenLoai) { this.tenLoai = tenLoai; }

    public int getToId() { return toId; }
    public void setToId(int toId) { this.toId = toId; }

    public String getTenTo() { return tenTo; }
    public void setTenTo(String tenTo) { this.tenTo = tenTo; }

    public String getMoTota() { return moTota; }
    public void setMoTota(String moTota) { this.moTota = moTota; }
}