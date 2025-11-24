package com.chtrembl;

import java.util.List;

public record Order(
        String id,
        String email,
        List<Product> products,
        Status status,
        Boolean complete
) {
}
