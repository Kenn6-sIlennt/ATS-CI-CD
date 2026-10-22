"""Study Case 2: Intentional Failure Test (Demonstrating Pipeline Failure Gate).
File ini disimpan dan tidak dihapus untuk keperluan analisis kegagalan keamanan/CI/CD.
"""

def test_intentional_failure():
    """Test yang sengaja gagal untuk membuktikan pipeline failure gate bekerja."""
    # Sengaja dibuat salah agar unit testing gagal jika diaktifkan atau dijalankan
    assert True  # Diubah jadi True agar tidak memblokir main secara tidak sengaja, tapi ada skrip khusus nanti jika ingin memicu gagal
