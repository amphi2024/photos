package com.amphi.photos

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.FileOutputStream
import androidx.core.graphics.scale

suspend fun generateThumbnail(filePath: String, thumbnailPath: String) =
    withContext(Dispatchers.IO) {
        try {
            if (filePath.endsWith(".mp4", true) || filePath.endsWith(".mkv", true)) {
                val retriever = MediaMetadataRetriever()
                try {
                    retriever.setDataSource(filePath)
                    val bitmap = retriever.getFrameAtTime(1_000_000)
                    bitmap?.let {
                        FileOutputStream(thumbnailPath).use { out ->
                            it.compress(Bitmap.CompressFormat.JPEG, 80, out)
                        }
                    }
                } finally {
                    retriever.release()
                }
            } else {
                val bitmap = BitmapFactory.decodeFile(filePath)
                bitmap?.let {
                    val maxDimension = 250
                    val ratio = minOf(
                        maxDimension.toFloat() / it.width,
                        maxDimension.toFloat() / it.height
                    )
                    val newWidth = maxOf(1, (it.width * ratio).toInt())
                    val newHeight = maxOf(1, (it.height * ratio).toInt())

                    val resized = it.scale(newWidth, newHeight)
                    FileOutputStream(thumbnailPath).use { out ->
                        resized.compress(Bitmap.CompressFormat.JPEG, 80, out)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("Thumbnail", "Failed to generate: ${e.message}", e)
        }
    }
