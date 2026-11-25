<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Nilai extends Model
{
    protected $table = 'nilais';

    protected $fillable = ['krs_id', 'nilai_angka'];

    public function krs(): BelongsTo
    {
        return $this->belongsTo(Krs::class);
    }

    public static function huruf(float $angka): string
    {
        return match (true) {
            $angka >= 80 => 'A',
            $angka >= 70 => 'B',
            $angka >= 60 => 'C',
            $angka >= 50 => 'D',
            default => 'E',
        };
    }

    public static function bobot(string $huruf): float
    {
        return match ($huruf) {
            'A' => 4.0,
            'B' => 3.0,
            'C' => 2.0,
            'D' => 1.0,
            default => 0.0,
        };
    }
}
