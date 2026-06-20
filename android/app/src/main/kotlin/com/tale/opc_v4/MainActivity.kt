package com.tale.opc_v4

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "opc_v4/korice_storage"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "savePdfToDownloadsKorice" -> {
                    val filename = call.argument<String>("filename")
                    val bytes = call.argument<ByteArray>("bytes")

                    if (filename.isNullOrBlank() || bytes == null) {
                        result.error("invalid_args", "filename/bytes are required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(savePdfToKorice(filename, bytes))
                    } catch (e: Exception) {
                        result.error("save_failed", e.message, null)
                    }
                }

                "saveDocumentToDownloadsKorice" -> {
                    val filename = call.argument<String>("filename")
                    val bytes = call.argument<ByteArray>("bytes")
                    val mimeType = call.argument<String>("mimeType")

                    if (filename.isNullOrBlank() || bytes == null || mimeType.isNullOrBlank()) {
                        result.error(
                            "invalid_args",
                            "filename/bytes/mimeType are required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(saveDocumentToKorice(filename, bytes, mimeType))
                    } catch (e: Exception) {
                        result.error("save_failed", e.message, null)
                    }
                }

                "listKoriceFiles" -> {
                    try {
                        result.success(listKoriceFiles())
                    } catch (e: Exception) {
                        result.error("list_failed", e.message, null)
                    }
                }

                "readKoriceFileBytes" -> {
                    val contentUri = call.argument<String>("contentUri")
                    if (contentUri.isNullOrBlank()) {
                        result.error("invalid_args", "contentUri is required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(readKoriceFileBytes(contentUri))
                    } catch (e: Exception) {
                        result.error("read_failed", e.message, null)
                    }
                }

                "openKoriceFile" -> {
                    val contentUri = call.argument<String>("contentUri")
                    val path = call.argument<String>("path")
                    if (contentUri.isNullOrBlank() && path.isNullOrBlank()) {
                        result.error("invalid_args", "contentUri or path is required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        openKoriceFile(contentUri, path)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("open_failed", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun savePdfToKorice(filename: String, bytes: ByteArray): Map<String, Any> {
        return saveDocumentToKorice(filename, bytes, "application/pdf")
    }

    private fun saveDocumentToKorice(
        filename: String,
        bytes: ByteArray,
        mimeType: String
    ): Map<String, Any> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveDocumentToPublicDownloadsMediaStore(filename, bytes, mimeType)
        } else {
            saveDocumentToLegacyDownloads(filename, bytes)
        }
    }

    private fun saveDocumentToPublicDownloadsMediaStore(
        filename: String,
        bytes: ByteArray,
        mimeType: String
    ): Map<String, Any> {
        val resolver = applicationContext.contentResolver
        val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/KORICE/"

        deleteExistingMediaStoreEntry(filename, relativePath)

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val itemUri = resolver.insert(collection, values)
            ?: throw IOException("Neuspelo kreiranje Downloads/KORICE stavke.")

        try {
            resolver.openOutputStream(itemUri)?.use { stream ->
                stream.write(bytes)
                stream.flush()
            } ?: throw IOException("Neuspelo otvaranje Downloads/KORICE izlaznog toka.")

            val finalizeValues = ContentValues().apply {
                put(MediaStore.Downloads.IS_PENDING, 0)
            }
            resolver.update(itemUri, finalizeValues, null, null)
            return mapOf(
                "name" to filename,
                "contentUri" to itemUri.toString(),
                "locationLabel" to "Downloads/KORICE"
            )
        } catch (e: Exception) {
            resolver.delete(itemUri, null, null)
            throw e
        }
    }

    private fun deleteExistingMediaStoreEntry(filename: String, relativePath: String) {
        val resolver = applicationContext.contentResolver
        val selection =
            "${MediaStore.MediaColumns.DISPLAY_NAME}=? AND ${MediaStore.MediaColumns.RELATIVE_PATH}=?"
        val args = arrayOf(filename, relativePath)
        resolver.delete(MediaStore.Downloads.EXTERNAL_CONTENT_URI, selection, args)
    }

    private fun saveDocumentToLegacyDownloads(
        filename: String,
        bytes: ByteArray
    ): Map<String, Any> {
        val downloadsDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val koriceDir = File(downloadsDir, "KORICE")
        if (!koriceDir.exists() && !koriceDir.mkdirs()) {
            throw IOException("Neuspelo kreiranje Downloads/KORICE foldera.")
        }

        val file = File(koriceDir, filename)
        FileOutputStream(file).use { stream ->
            stream.write(bytes)
            stream.flush()
        }
        return mapOf(
            "name" to filename,
            "path" to file.absolutePath,
            "locationLabel" to "Downloads/KORICE"
        )
    }

    private fun listKoriceFiles(): List<Map<String, Any>> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            listKoriceFilesMediaStore()
        } else {
            listKoriceFilesLegacy()
        }
    }

    private fun listKoriceFilesMediaStore(): List<Map<String, Any>> {
        val resolver = applicationContext.contentResolver
        val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/KORICE/"
        val projection = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DISPLAY_NAME,
            MediaStore.MediaColumns.DATE_MODIFIED
        )
        val selection = "${MediaStore.MediaColumns.RELATIVE_PATH}=?"
        val args = arrayOf(relativePath)
        val sortOrder = "${MediaStore.MediaColumns.DATE_MODIFIED} DESC"

        val items = mutableListOf<Map<String, Any>>()
        resolver.query(
            MediaStore.Downloads.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            args,
            sortOrder
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
            val nameIndex = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)
            val modifiedIndex =
                cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATE_MODIFIED)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idIndex)
                val name = cursor.getString(nameIndex) ?: continue
                val modifiedSeconds = cursor.getLong(modifiedIndex)
                val uri = Uri.withAppendedPath(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    id.toString()
                )

                items.add(
                    mapOf(
                        "name" to name,
                        "modifiedEpochMs" to (modifiedSeconds * 1000L),
                        "contentUri" to uri.toString(),
                        "locationLabel" to "Downloads/KORICE"
                    )
                )
            }
        }

        return items
    }

    private fun listKoriceFilesLegacy(): List<Map<String, Any>> {
        val downloadsDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val koriceDir = File(downloadsDir, "KORICE")
        if (!koriceDir.exists()) {
            return emptyList()
        }

        return koriceDir.listFiles()
            ?.filter { it.isFile }
            ?.sortedByDescending { it.lastModified() }
            ?.map { file ->
                mapOf(
                    "name" to file.name,
                    "modifiedEpochMs" to file.lastModified(),
                    "path" to file.absolutePath,
                    "locationLabel" to "Downloads/KORICE"
                )
            }
            ?: emptyList()
    }

    private fun readKoriceFileBytes(contentUri: String): ByteArray {
        val uri = Uri.parse(contentUri)
        return applicationContext.contentResolver.openInputStream(uri)?.use { stream ->
            stream.readBytes()
        } ?: throw IOException("Neuspelo čitanje Downloads/KORICE dokumenta.")
    }
    private fun openKoriceFile(contentUri: String?, path: String?) {
        val uri = when {
            !contentUri.isNullOrBlank() -> Uri.parse(contentUri)
            !path.isNullOrBlank() -> FileProvider.getUriForFile(
                applicationContext,
                "${applicationContext.packageName}.fileprovider",
                File(path)
            )
            else -> throw IOException("Nedostaje referenca na KORICE dokument za otvaranje.")
        }

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        applicationContext.startActivity(intent)
    }
}
