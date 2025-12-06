package com.chtrembl.petstore.product.service;

import com.chtrembl.petstore.product.entity.ProductEntity;
import com.chtrembl.petstore.product.mapper.ProductMapper;
import com.chtrembl.petstore.product.model.Product;
import com.chtrembl.petstore.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.StreamSupport;

@Service
@Slf4j
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    public List<Product> findProductsByStatus(List<String> status) {
        log.info("Finding products with status: {}", status);

        List<ProductEntity> entities = productRepository.findByStatusIn(status);
        return ProductMapper.toModelList(entities);
    }

    public Optional<Product> findProductById(String productId) {
        log.info("Finding product with id: {}", productId);

        Optional<ProductEntity> entity = productRepository.findById(productId);
        return entity.map(ProductMapper::toModel);
    }

    public List<Product> getAllProducts() {
        log.info("Getting all products");
        List<ProductEntity> entities = StreamSupport.stream(productRepository.findAll().spliterator(), false).toList();
        return ProductMapper.toModelList(entities);
    }

    public int getProductCount() {
        return (int) productRepository.count();
    }
}