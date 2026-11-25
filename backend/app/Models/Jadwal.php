<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Jadwal extends Model
{
    protected $table = 'jadwals';

    protected $fillable = [
        'mata_kuliah_id', 'tahun_ajaran', 'dosen_id', 'dosen', 'hari', 'jam_mulai', 'jam_selesai', 'ruang', 'kuota',
    ];

    public function mataKuliah(): BelongsTo
    {
        return $this->belongsTo(MataKuliah::class);
    }

    public function krs(): HasMany
    {
        return $this->hasMany(Krs::class);
    }

    /** Bentuk JSON datar yang dipakai aplikasi Flutter. */
    public function toApi(): array
    {
        return [
            'jadwal_id' => $this->id,
            'kode' => $this->mataKuliah->kode,
            'nama' => $this->mataKuliah->nama,
            'sks' => $this->mataKuliah->sks,
            'dosen' => $this->dosen,
            'hari' => $this->hari,
            'jam_mulai' => substr($this->jam_mulai, 0, 5),
            'jam_selesai' => substr($this->jam_selesai, 0, 5),
            'ruang' => $this->ruang,
        ];
    }
}
