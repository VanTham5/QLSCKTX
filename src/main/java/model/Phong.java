package model;

public class Phong {
    private int phongId;
    private String maPhong;
    private String toaNha;
    private int tang;
    private String loaiPhong;
    private String trangThai;
    private int soSinhVien;

    public Phong() {
    }

    public Phong(int phongId, String maPhong, String toaNha, int tang, String loaiPhong, String trangThai, int soSinhVien) {
        this.phongId = phongId;
        this.maPhong = maPhong;
        this.toaNha = toaNha;
        this.tang = tang;
        this.loaiPhong = loaiPhong;
        this.trangThai = trangThai;
        this.soSinhVien = soSinhVien;
    }

    public int getPhongId() {
        return phongId;
    }

    public void setPhongId(int phongId) {
        this.phongId = phongId;
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getToaNha() {
        return toaNha;
    }

    public void setToaNha(String toaNha) {
        this.toaNha = toaNha;
    }

    public int getTang() {
        return tang;
    }

    public void setTang(int tang) {
        this.tang = tang;
    }

    public String getLoaiPhong() {
        return loaiPhong;
    }

    public void setLoaiPhong(String loaiPhong) {
        this.loaiPhong = loaiPhong;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public int getSoSinhVien() {
        return soSinhVien;
    }

    public void setSoSinhVien(int soSinhVien) {
        this.soSinhVien = soSinhVien;
    }
}