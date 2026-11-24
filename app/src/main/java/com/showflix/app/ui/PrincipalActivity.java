package com.showflix.app.ui;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.showflix.app.R;

public class PrincipalActivity extends AppCompatActivity {
    private RecyclerView recCatalogo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_principal);
        recCatalogo = findViewById(R.id.rec_catalogo);
        recCatalogo.setLayoutManager(new GridLayoutManager(this, 3));
    }
}
